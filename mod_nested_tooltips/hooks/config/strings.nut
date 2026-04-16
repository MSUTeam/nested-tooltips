// Adapt vanilla getArticle functions to return the article
// for the text within the tooltip tags.
local getArticle = ::Const.Strings.getArticle;
::Const.Strings.getArticle = { function getArticle( _object )
{
	if (typeof _object != "string")
		return getArticle(_object);

	local idx = _object.find("[tooltip=");
	if (idx != null)
	{
		_object = _object.slice(_object.find("]") + 1, _object.find("[/tooltip"));
	}
	return getArticle(_object);
}}.getArticle;

local getArticleCapitalized = ::Const.Strings.getArticleCapitalized;
::Const.Strings.getArticleCapitalized = { function getArticleCapitalized( _object )
{
	if (typeof _object != "string")
		return getArticleCapitalized(_object);

	local idx = _object.find("[tooltip=");
	if (idx != null)
	{
		_object = _object.slice(_object.find("]") + 1, _object.find("[/tooltip"));
	}
	return getArticleCapitalized(_object);
}}.getArticleCapitalized;
