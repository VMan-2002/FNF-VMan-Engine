import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;

//original by doggydentures
class ColorblindShader extends Shader {
    //todo: should i add more?
    public static var filterList = [
        "protanopia_correct",
        "deuteranopia_correct",
        "tritanopia_correct",
        "protanopia_simulate",
        "deuteranopia_simulate",
        "tritanopia_simulate"
    ];

    public var intensity(default, set):Float;
    public var valid:Bool = false;
    public static var instanceFilter:Null<ShaderFilter>;

    public function set_intensity(val:Float) {
        return intensity = val;
    }

    public function new(type:String) {
        super();
        if (!filterList.contains(type)) {
            instanceFilter = null;
            return trace("Colorblind type not found: "+type);//you're up to no good?
        }
        valid = true;
        instanceFilter = new ShaderFilter(this);
        var mat = switch(type) {
            case "deuteranopia_correct" | "deuteranopia_simulate":
                "1.0,      0.0, 0.0,
                0.494207, 0.0, 1.24827,
                0.0,      0.0, 1.0";
            case "protanopia_correct" | "protanopia_simulate":
                "0.0, 2.02344, -2.52581,
                0.0, 1.0,      0.0,
                0.0, 0.0,      1.0";
            case "tritanopia_correct" | "tritanopia_simulate":
                "1.0,       0.0,      0.0,
                0.0,       1.0,      0.0,
                -0.012245, 0.072035, 0.0";
            default:
                null;
        }
        var correction = switch(type) {
            case "protanopia_correct" | "deuteranopia_correct" | "tritanopia_correct":
                "z = (RGB - z) * mat3(
                    0.0, 0.0, 0.0,
                    0.7, 1.0, 0.0,
                    0.7, 0.0, 1.0
                ) * intensity; z = z + RGB;";
            default:
                "";
        }
        glFragmentSource = "#pragma header
        uniform float intensity;
        const mat3 RGB_to_LMS = mat3(
            17.8824,   43.5161,  4.11935,
            3.45565,   27.1554,  3.86714,
            0.0299566, 0.184309, 1.46709
        );
        const mat3 LMS_to_RGB = mat3(
            0.0809444479,   -0.130504409,    0.116721066,
            -0.0102485335,    0.0540193266,  -0.113614708,
            -0.000365296938, -0.00412161469,  0.693511405
        );
        
        void main()
        {
            vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);
            vec4 dst;
            
            vec3 RGB = tex.rgb;
            vec3 z = RGB * RGB_to_LMS;
            z = z * mat3(" + mat + ");
            z = z * LMS_to_RGB;
        " + correction + "
            dst.r = z.r;
            dst.g = z.g;
            dst.b = z.b;
            dst.a = tex.a;
            gl_FragColor = dst;
        }";
    }
}

//thing that *i* made
class ColorGuys extends FlxTypedSpriteGroup<FlxSprite> {
    var stuffHeight:Float = 80;
    var stuffWidth:Float = 100;
    var danceTime:Float = 0;
    var bf:Character = new Character(0, 0, "bf", true);

    public override function new(x:Float, y:Float) {
        super(x, y);
        bf.dance();
        add(bf);

        var mania = ManiaInfo.GetManiaInfo("17k");
        for (col in 0...mania.keys) {
            var note = new ChartingNote(0, col, null, false, mania);
            note.setGraphicSize(72);
            note.setPosition(col * 75, 10 + bf.frameHeight);
            add(note);
        }

        stuffHeight += bf.frameHeight;
        stuffWidth *= mania.keys;
        if (bf.frameWidth > stuffWidth)
            stuffWidth = bf.frameWidth;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        danceTime += elapsed;
        if (danceTime >= 0.7) {
            danceTime -= 0.7;
            bf.dance();
        }
    }
}