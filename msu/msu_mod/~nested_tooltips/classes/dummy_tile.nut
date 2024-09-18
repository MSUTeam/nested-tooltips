::MSU.Class.DummyPlayerTile <- class {
	ID = 0;

	function hasZoneOfControlOtherThan( ... )
	{
		return false;
	}

	function getZoneOfControlCountOtherThan( ... )
	{
		return 0;
	}
};
