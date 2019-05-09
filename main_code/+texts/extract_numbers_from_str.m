function numOut = extract_numeric(txtStr)
% numOut = EXTRACT_NUMERIC(txtStr)

numOut = [];
numCnt = 1;


strCnt = 1;
while strCnt<=length(txtStr)
    buildNum = '';
    if ~isempty(str2num(txtStr(strCnt)))
        while ~isempty(str2num(txtStr(strCnt)))
            buildNum(end+1) = txtStr(strCnt);
            strCnt = strCnt+1;
        end
        numOut(numCnt) = str2num(buildNum);
         numCnt = numCnt+1;
    else
        strCnt = strCnt+1;
    end
    

   
end




end