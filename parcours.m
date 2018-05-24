function [ l ] = parcours( M )
    [h, w] = size(M);
    l = [];
    dir = [-1, 1];
    for i=1:(h + w - 1)
        sens = mod(i, 2) * 2 - 1;
        if(sens == 1)
           if(i <= h)
               start = [i, 1];
           else
               start = [h, i - h + 1];
           end
        else
            if(i <= w)
                start = [1, i];
            else
                start = [i - w + 1, w];
            end
        end
        while(start(1) >= 1 && start(1) <= h && start(2) >= 1 && start(2) <= w)
           l = [l; M(start(1),start(2))];
           start = start + dir * sens;
        end
    end

end

