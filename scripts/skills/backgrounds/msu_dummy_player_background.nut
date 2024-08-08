this.msu_dummy_player_background <- ::inherit("scripts/skills/backgrounds/character_background", {
	m = {},
	function create()
	{
		this.character_background.create();
		this.m.ID = "background.msu_dummy_player";
		this.m.Name = "MSU Dummy Player Background";
		this.m.Icon = "ui/backgrounds/background_40.png";
		this.m.BackgroundDescription = "";
		this.m.GoodEnding = "";
		this.m.BadEnding = "";
		this.m.HiringCost = 90;
		this.m.DailyCost = 8;
		this.m.Faces = this.Const.Faces.AllMale;
		this.m.Hairs = this.Const.Hair.YoungMale;
		this.m.HairColors = this.Const.HairColors.Young;
		this.m.Beards = this.Const.Beards.All;
		this.m.Bodies = this.Const.Bodies.Muscular;
	}

	// Overwrite the original function because it tries to access villages etc. and causes
	// an error when this is triggered during FirstWorldInit bucket
	function buildDescription( _isFinal = false )
	{
	}

	function onAddEquipment()
	{
	}
});
