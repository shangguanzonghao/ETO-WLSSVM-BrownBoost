function v1 = weights(e, C1, C2)

    c1 = C1;
    c2 = C2;
    m = size(e, 1);
    v = zeros(m, 1);
    v1 = eye(m);
    q1 = floor(m / 4);
    q3 = floor((m * 3) / 4);
    e1 = zeros(m, 1);
    shang = zeros(m, 1);

 
    for i = 1:m
        e1(i) = e(i, 1);
    end
    e1 = sort(e1);

   
    IQR = e1(q3 + 1) - e1(q1 + 1); 


    s = IQR / (2 * 0.6745);

  
    for j = 1:m
        shang(j) = abs(e(j, 1) / s);
        if shang(j) <= c1
            v(j) = 1.0;
        elseif shang(j) > c1 && shang(j) <= c2
            v(j) = (c2 - shang(j)) / (c2 - c1);
        else
            v(j) = 1e-4;
        end
        v1(j, j) = 1 / v(j);
    end
end
