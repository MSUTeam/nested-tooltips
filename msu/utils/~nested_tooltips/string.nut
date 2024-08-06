::MSU.String.regexReplace <- function( _string, _findRegex, _replaceFunction )
{
	if (typeof _findRegex == "string")
		_findRegex = regexp(_findRegex);
	local match;
	local out = "";
	local lastPos = 0;
	while (match = _findRegex.capture(_string, lastPos))
	{
		out += _string.slice(lastPos, match[0].begin);
		local args = [this];
		foreach (subMatch in match)
			args.push(_string.slice(subMatch.begin, subMatch.end));
		out += _replaceFunction.acall(args);
		lastPos = match[0].end;
	}
	return out + _string.slice(lastPos);
}
