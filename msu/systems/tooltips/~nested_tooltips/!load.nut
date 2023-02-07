local function includeFile( _file )
{
	::include("msu/systems/tooltips/~nested_tooltips/" + _file);
}

includeFile("tooltips_system");
includeFile("tooltips_mod_addon");
