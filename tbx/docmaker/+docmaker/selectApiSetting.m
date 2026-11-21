function value = selectApiSetting( environmentValue, secretValue, defaultValue )
%docmaker.selectApiSetting  Select a setting from its available sources
%
%   VALUE = docmaker.selectApiSetting(ENVIRONMENT,SECRET,DEFAULT) returns
%   the first nonempty value in environment, secret, default order.

%   Copyright 2026 The MathWorks, Inc.

arguments
    environmentValue (1,1) string
    secretValue (1,1) string
    defaultValue (1,1) string
end

if strlength( environmentValue ) > 0
    value = environmentValue;
elseif strlength( secretValue ) > 0
    value = secretValue;
else
    value = defaultValue;
end

end % selectApiSetting
