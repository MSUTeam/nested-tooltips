local encodedString = "[" + ::MSU.Class.TooltipsModAddon.encodeString("tooltip") + "=";

// Adapt vanilla getArticle functions to return the article
// for the text within the tooltip tags.
local getArticle = ::Const.Strings.getArticle;
::Const.Strings.getArticle = { function getArticle( _object )
{
	if (typeof _object != "string" || _object.len() < 9) // i.e. shorter than "[tooltip="
		return getArticle(_object);

	if (_object.slice(0, 9) == "[tooltip=" || _object.len() >= encodedString.len() && _object.slice(0, encodedString.len()) == encodedString)
	{
		_object = _object.slice(_object.find("]") + 1);
	}

	return getArticle(_object);
}}.getArticle;

local getArticleCapitalized = ::Const.Strings.getArticleCapitalized;
::Const.Strings.getArticleCapitalized = { function getArticleCapitalized( _object )
{
	if (typeof _object != "string" || _object.len() < 9) // i.e. shorter than "[tooltip="
		return getArticleCapitalized(_object);

	if (_object.slice(0, 9) == "[tooltip=" || _object.len() >= encodedString.len() && _object.slice(0, encodedString.len()) == encodedString)
	{
		_object = _object.slice(_object.find("]") + 1);
	}

	return getArticleCapitalized(_object);
}}.getArticleCapitalized;
