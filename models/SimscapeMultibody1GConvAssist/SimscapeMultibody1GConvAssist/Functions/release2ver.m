function verNum = release2ver(releaseNum)

releaseNumSet = {
    '7.14','R2012a';
    '8.0', 'R2012b';
    '8.1', 'R2013a';
    '8.2', 'R2013b';
    '8.3', 'R2014a';
    '8.4', 'R2014b';
    '8.5', 'R2015a';
    '8.6', 'R2015b';
    '9.0', 'R2016a';
    '9.1', 'R2016b';
    '9.2', 'R2017a';
    '9.3', 'R2017b';
    };

ind = strcmpi(releaseNumSet(:,2),releaseNum);
verNum = releaseNumSet{ind,1};


