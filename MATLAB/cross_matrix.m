function v_x = cross_matrix(v)

% Create 3x3 matrix v_x in cross-product form from 3x1 vector v

v_x = [0, -v(3), v(2);
       v(3), 0, -v(1);
       -v(2), v(1), 0];


end

