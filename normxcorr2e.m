function I = normxcorr2e(template,im,shape)

%# perform cross correlation with automated zero-padding
I = normxcorr2(template,im);

switch shape
    case 'same'

        %# if we were guaranteed to have odd-sized templates only
        %# we would only need padLow
        templateSize = size(template);
        padLow = floor(templateSize/2);
        padHigh = templateSize - padLow - 1;

        I = I( (1+padLow(1)):(end-padHigh(1)), (1+padLow(2)):(end-padHigh(2)) );

    case 'full'
        %Do nothing
    case 'valid'
        %# with even size, we need to remove the larger of the two pad sizes
        %# i.e. padLow, on all sides
        templateSize = size(template);
        padLow = templateSize/2;

        I = I( (2*padLow(1)):(end-2*padLow(1)+1), (2*padLow(2)):(end-2*padLow(2)+1) );
    otherwise
        throw(Mexception('normxcorr2e:BadInput','shape %s is not recognized',shape));
end