// Adapt vanilla getArticle functions to return the article
// for the text within the tooltip tags.
local getArticle = ::Const.Strings.getArticle;
::Const.Strings.getArticle = { function getArticle( _object )
{
	return typeof _object != "string" ? getArticle(_object) : getArticle(::MSU.Mod.Tooltips.removeAllFromString(_object));
}}.getArticle;

local getArticleCapitalized = ::Const.Strings.getArticleCapitalized;
::Const.Strings.getArticleCapitalized = { function getArticleCapitalized( _object )
{
	return typeof _object != "string" ? getArticleCapitalized(_object) : getArticleCapitalized(::MSU.Mod.Tooltips.removeAllFromString(_object));
}}.getArticleCapitalized;
