package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import Shaders.PulseEffect;
#if shaders
import openfl.filters.ShaderFilter;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.2h'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	public var screenshader:Shaders.PulseEffect = new PulseEffect();
	public var curbg:FlxSprite;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'fart',
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		'options'
	];

	var magenta:FlxSprite;
	var fartshit:FlxSprite;
	var creditfuck:FlxSprite;
	var freeplaypenis:FlxSprite;
	var optioncum:FlxSprite;
	var awardfeces:FlxSprite;
	var saggy:FlxSprite;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var placebg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('placeholderbg'));
		placebg.scrollFactor.set(0, 0);
		placebg.setGraphicSize(Std.int(placebg.width * 1.175));
		placebg.updateHitbox();
		placebg.screenCenter();
		placebg.antialiasing = ClientPrefs.globalAntialiasing;
		add(placebg);

		var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
		testshader.waveAmplitude = 0.1;
		testshader.waveFrequency = 5;
		testshader.waveSpeed = 2;
		placebg.shader = testshader.shader;
		curbg = placebg;

		saggy = new FlxSprite(-620, -130);
		saggy.scale.set(1.2, 1.2);
		saggy.frames = Paths.getSparrowAtlas('menuShaggy');
		saggy.animation.addByPrefix('idle', 'shaggy_idle', 24);
		saggy.animation.play('idle');
		saggy.antialiasing = ClientPrefs.globalAntialiasing;
		add(saggy);

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		// tried to only use 1 magenta graphic thing but i couldnt get it to change size depending on what was selected
		awardfeces = new FlxSprite(870, 610).loadGraphic(Paths.image('magentashit'));
		awardfeces.scrollFactor.set(0, 0);
		awardfeces.scale.set(435, 112);
		awardfeces.visible = false;
		awardfeces.updateHitbox();
		awardfeces.antialiasing = ClientPrefs.globalAntialiasing;
		add(awardfeces);

		optioncum = new FlxSprite(0, 610).loadGraphic(Paths.image('magentashit'));
		optioncum.scrollFactor.set(0, 0);
		optioncum.scale.set(435, 112);
		optioncum.visible = false;
		optioncum.updateHitbox();
		optioncum.antialiasing = ClientPrefs.globalAntialiasing;
		add(optioncum);

		freeplaypenis = new FlxSprite(440, 610).loadGraphic(Paths.image('magentashit'));
		freeplaypenis.scrollFactor.set(0, 0);
		freeplaypenis.scale.set(430, 112);
		freeplaypenis.visible = false;
		freeplaypenis.updateHitbox();
		freeplaypenis.antialiasing = ClientPrefs.globalAntialiasing;
		add(freeplaypenis);

		creditfuck = new FlxSprite(0, 0).loadGraphic(Paths.image('magentashit'));
		creditfuck.scrollFactor.set(0, 0);
		creditfuck.scale.set(404, 112);
		creditfuck.visible = false;
		creditfuck.updateHitbox();
		creditfuck.antialiasing = ClientPrefs.globalAntialiasing;
		add(creditfuck);

		fartshit = new FlxSprite(910, 0).loadGraphic(Paths.image('magentashit'));
		fartshit.scrollFactor.set(0, 0);
		fartshit.scale.set(404, 112);
		fartshit.visible = false;
		fartshit.updateHitbox();
		fartshit.antialiasing = ClientPrefs.globalAntialiasing;
		add(fartshit);

		magenta = new FlxSprite(410, 0).loadGraphic(Paths.image('magentashit'));
		magenta.scrollFactor.set(0, 0);
		magenta.scale.set(500, 112);
		magenta.updateHitbox();
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		add(magenta);
		
		// magenta.scrollFactor.set();

		var lines:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('fuckinlines'));
		lines.scrollFactor.set(0, 0);
		lines.setGraphicSize(Std.int(lines.width * 1.175));
		lines.updateHitbox();
		lines.screenCenter();
		lines.antialiasing = ClientPrefs.globalAntialiasing;
		add(lines);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(500, 0);
			menuItem.scale.set(0.8, 0.8);
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			switch(optionShit[i])
			{
				case "story_mode": 
					menuItem.x = 415;
					menuItem.y = -90;
					menuItem.scale.set(0.75, 0.75);
				case "freeplay": 
					menuItem.x = 460;
					menuItem.y = 520;
				case "awards": 
					menuItem.x = 900;
					menuItem.y = 520;
				case "options": 
					menuItem.x = 30;
					menuItem.y = 530;
				case "credits": 
					menuItem.x = 20;
					menuItem.y = -90;
					menuItem.scale.set(0.75, 0.75);
				case "fart": 
					menuItem.x = 950;
					menuItem.y = -90;
					menuItem.scale.set(1, 0.8);
			}
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (curbg != null)
		{
			if (curbg.active)
			{
			var shad = cast(curbg.shader,Shaders.GlitchShader);
			shad.uTime.value[0] += elapsed;
			}
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				if (optionShit[curSelected] == 'story_mode')
				{
					changeItem(4);
				} else {
					changeItem(-2);
				}
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				if (optionShit[curSelected] == 'options')
				{
					changeItem(-4);
				} else {
					changeItem(2);
				}
			}

			if (controls.UI_DOWN_P || controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				if (optionShit[curSelected] == 'story_mode' || optionShit[curSelected] == 'fart' || optionShit[curSelected] == 'credits')
				{
					changeItem(1);
				} 
				else if (optionShit[curSelected] == 'awards' || optionShit[curSelected] == 'freeplay' || optionShit[curSelected] == 'options')
				{
					changeItem(-1);
				}
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'fart')
				{
					FlxG.sound.play(Paths.sound('shitted'));
					FlxG.camera.shake(0.0085, 0.15);
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));


					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
			if (optionShit[curSelected] == 'story_mode')
				{
					magenta.visible = true;
					fartshit.visible = false;
					creditfuck.visible = false;
					freeplaypenis.visible = false;
					optioncum.visible = false;
					awardfeces.visible = false;
				}
			if (optionShit[curSelected] == 'freeplay')
				{
					magenta.visible = false;
					fartshit.visible = false;
					creditfuck.visible = false;
					freeplaypenis.visible = true;
					optioncum.visible = false;
					awardfeces.visible = false;
				}
			if (optionShit[curSelected] == 'options')
				{
					magenta.visible = false;
					fartshit.visible = false;
					creditfuck.visible = false;
					freeplaypenis.visible = false;
					optioncum.visible = true;
					awardfeces.visible = false;
				}
			if (optionShit[curSelected] == 'fart')
				{
					magenta.visible = false;
					fartshit.visible = true;
					creditfuck.visible = false;
					freeplaypenis.visible = false;
					optioncum.visible = false;
					awardfeces.visible = false;
				}
			if (optionShit[curSelected] == 'credits')
				{
					magenta.visible = false;
					fartshit.visible = false;
					creditfuck.visible = true;
					freeplaypenis.visible = false;
					optioncum.visible = false;
					awardfeces.visible = false;
				}
			if (optionShit[curSelected] == 'awards')
				{
					magenta.visible = false;
					fartshit.visible = false;
					creditfuck.visible = false;
					freeplaypenis.visible = false;
					optioncum.visible = false;
					awardfeces.visible = true;
				}
		}

		super.update(elapsed);

	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

	}
}
