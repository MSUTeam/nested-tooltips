::MSU.Class.DummyPlayerTile <- class {
	static ID = 0;
	static Level = 0;
	static IsBadTerrain = false;
	static Type = ::Const.Tactical.TerrainType.Impassable;
	static Subtype = ::Const.Tactical.TerrainSubtype.None;
	static IsHidingEntity = false;
	static IsContainingItems = false;
	static IsSpecialTerrain = false;
	static IsContainingItemsFlipped = false;
	static IsDiscovered = false;
	static IsDefensibleTerrain = false;
	static IsVisibleForEntity = false;
	static IsVisibleForPlayer = false;
	static IsCorpseSpawned = false;
	static IsOccupiedByActor = false;

	function hasZoneOfControlOtherThan( ... )
	{
		return false;
	}

	function getZoneOfControlCountOtherThan( ... )
	{
		return 0;
	}

	function getZoneOfControlCount( ... )
	{
		return 0;
	}

	function hasZoneOfOccupationOtherThan( ... )
	{
		return false;
	}

	function getZoneOfOccupationCount( ... )
	{
		return 0;
	}

	function getZoneOfOccupationCountOtherThan( ... )
	{
		return 0;
	}

	function hasNextTile( ... )
	{
		return false;
	}

	function hasLineOfSightTo( ... )
	{
		return false;
	}

	function isSameTileAs( _tile )
	{
		return false;
	}
};

/*
MSU.Log.printData output for Tile:
<__sqrat_ol_ clear_1 = Function, __sqrat_ol_ clear_0 = Function, getDirectionTo = Function, getZoneOfOccupationCount = Function, isSameTileAs = Function, addZoneOfControl = Function, hasZoneOfControlOtherThan = Function, __setTable = Table, removeZoneOfOccupation = Function, removeZoneOfControl = Function, hasLineOfSightTo = Function, addVisibilityForFaction = Function, getTileBetweenThisAnd = Function, getPosBetweenThisAnd = Function, addVisibilityForCurrentEntity = Function, removeObject = Function, getZoneOfControlCount = Function, setColor = Function, getNextTile = Function, spawnObject = Function, getDirection8To = Function, hasNextTile = Function, __sqrat_ol_ getDistanceTo_2 = Function, __sqrat_ol_ getDistanceTo_1 = Function, getZoneOfControlCountOtherThan = Function, getZoneOfOccupationCountOtherThan = Function, hasZoneOfOccupationOtherThan = Function, __sqrat_ol_ setColor_1 = Function, getDistanceTo = Function, __sqrat_ol_ setColor_3 = Function, clear = Function, setBrush = Function, spawnDetail = Function, addZoneOfOccupation = Function, weakref = Function, __sqrat_ol_ spawnDetail_1 = Function, constructor = Function, __sqrat_ol_ spawnDetail_3 = Function, __sqrat_ol_ spawnDetail_2 = Function, __sqrat_ol_ spawnDetail_5 = Function, __sqrat_ol_ spawnDetail_4 = Function, getEntity = Function, __getTable = Table>

For Tile.__setTable:
{Level = Function, IsBadTerrain = Function, Type = Function, BlendPriority = Function, IsHidingEntity = Function, IsContainingItems = Function, IsSpecialTerrain = Function, IsContainingItemsFlipped = Function, Subtype = Function, IsDefensibleTerrain = Function}

For Tile.__getTable:
{Level = Function, IsBadTerrain = Function, IsDiscovered = Function, BlendPriority = Function, IsDefensibleTerrain = Function, IsVisibleForEntity = Function, IsVisibleForPlayer = Function, Properties = Function, IsSpecialTerrain = Function, Pos = Function, IsCorpseSpawned = Function, TVTotal = Function, Coords = Function, TVHeight = Function, IsEmpty = Function, TVTerrain = Function, IsOccupiedByActor = Function, ID = Function, TVLevelDisadvantage = Function, IsHidingEntity = Function, Y = Function, X = Function, IsContainingItems = Function, SquareCoords = Function, IsContainingItemsFlipped = Function, Type = Function, Items = Function, Subtype = Function}
*/
