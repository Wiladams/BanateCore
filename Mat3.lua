Mat3_Included = true

if not BanateCore_000 then
require "000"
end

if not vec_func_included then
require "01_vec_func"
end

if not Mat_Included then
require "Mat"
end

mat3 = ffi.typeof("double[3][3]")

-- Identity matrix for a 4x4 matrix
mat3_identity =  mat3({1,0,0}, {0,1,0}, {0,0,1})


function mat3_new(a,b,c,d,e,f,g,h,i)
	a = a or 0
	b = b or 0
	c = c or 0

	d = d or 0
	e = e or 0
	f = f or 0

	g = g or 0
	h = h or 0
	i = i or 0

	return mat3({a,b,c}, {d,e,f}, {g,h,i})
end

local function mat3_assign(a, b)
	for row=0,2 do
		for col =0,2 do
			a[row][col] = b[row][col]
		end
	end

	return a
end

local function mat3_clone(m)
	return mat3_assign(mat3(), m)
end

local function mat3_get_col(m, col)
	return SquareMatrix.GetColumn(vec3(), m, col, 3)
end

local function mat3_set_col(m, col, vec)
	return SquareMatrix.SetColumn(m, col, vec, 3)
end


local function mat3_get_row(m, row)
	return vec3(m[row][0], m[row][1], m[row][2])
end

local function mat3_set_row(m, row, vec)
	m[row][0] = vec[0]
	m[row][1] = vec[1]
	m[row][2] = vec[2]
end



local function mat3_get_rows(m)
	return m[0], m[1], m[2]
end

local function mat3_set_rows(m, row0, row1, row2)
	mat3_set_row(m, 0, row0)
	mat3_set_row(m, 1, row1)
	mat3_set_row(m, 2, row2)
end



local function mat3_get_diagonal(res, m)
	res[0] = m[0][0]
	res[1] = m[1][1]
	res[2] = m[2][2]

	return res
end

local function mat3_get_diagonal_new(m)
	return SquareMatrix.GetDiagonal(vec3(), m, 3)
end


-- Matrix Addition
local function mat3_add_mat3(res, a, b)
	for row=0,2 do
		res[row][0] = a[row][0]+b[row][0]
		res[row][1] = a[row][1]+b[row][1]
		res[row][2] = a[row][2]+b[row][2]
	end
end

local function mat3_add_mat3_new(a, b)
	return mat3_add_mat3(mat3(), a, b)
end


-- Matrix Subtraction
local function mat3_sub_mat3(res, a, b)
	for row=0,2 do
		res[row][0] = a[row][0]-b[row][0]
		res[row][1] = a[row][1]-b[row][1]
		res[row][2] = a[row][2]-b[row][2]
	end
end

local function mat3_sub_mat3_new(a, b)
	return mat3_sub_mat3(mat3(), a, b)
end


-- Matrix Multiplication

local function mat3_mul_mat3(res, a, b)
	local n = 3

	for i=0,n-1 do
		for j=0,n-1 do
			res[i][j]=0
			for k=0,n-1 do
				res[i][j] = res[i][j] + a[i][k]*b[k][j]
			end
		end
	end
	return res
end



local function mat3_mul_mat3_new(a, b)
	return mat_mul_mat(mat3(), a, b, 3)
end


local function mat3_transpose_new(a)
	return SquareMatrix.Transpose(mat3(), a, 3)
end



--[[
local function mat3_sub_determinant(m, i, j)
    local x, y, ii, jj;
    local ret;
	local m3 = mat3();

	function m3G(row,col)
		return m3[row*3+col]
	end

	function m3P(row,col, value)
		m3[row*3+col] = value
	end

    x = 0;
    for ii = 0, 3 do
		if (ii ~= i) then
			y = 0;

			for jj = 0,3 do
				if (jj ~= j) then

					m3P(x,y,m[(ii*4)+jj]);

					y = y + 1;
				end
			end

			x = x+1;
		end
	end

    ret = m3G(0,0)*(m3G(1,1)*m3G(2,2)-m3G(2,1)*m3G(1,2));
    ret = ret - m3G(0,1)*(m3G(1,0)*m3G(2,2)-m3G(2,0)*m3G(1,2));
    ret = ret + m3G(0,2)*(m3G(1,0)*m3G(2,1)-m3G(2,0)*m3G(1,1));

    return ret;
end


function mat3_inverse(mInverse, m)
    local i, j;
    local det =0
	local detij;

    -- First, calculate the sub determinant
    for i = 0,3 do
		local subdet = 0
		if band(i,0x1) > 0 then
			subdet = (-m[i] * mat3_sub_determinant(m, 0, i))
		else
			subdet = (m[i] * mat3_sub_determinant(m, 0,i))
		end

		det = det + subdet
	end

    det = 1 / det;

    -- calculate inverse
    for i = 0,3  do
        for j = 0,3 do
            detij = mat3_sub_determinant(m, j, i);
			local scratch
			if (band((i+j), 0x1) > 0) then
				scratch = (-detij * det)
			else
				scratch = (detij *det)
			end

            mInverse[(i*4)+j] = scratch;
		end
	end

	return mInverse
end

function mat3_inverse_new(m)
	return mat3_inverse(mat3(), m)
end
--]]



--[[
		TRANSFORMATION  MATRICES
--]]
local function mat3_create_translation(res, x, y)
	res[2][0] = x
	res[2][1] = y

	return res
end

local function mat3_create_translation_new(x,y)
	return mat3_create_translation(mat3_clone(mat3_identity), x, y)
end

-- Matrix creation
local function mat3_create_scale(res, x, y, z)
	res[0][0] = x
	res[1][1] = y
	res[2][2] = z

	return res
end

local function mat3_create_scale_new(x,y,z)
	x = x or 1
	y = y or 1
	z = z or 1

	return mat3_create_scale(mat3_clone(mat3_identity), x, y, z)
end



-- Create Rotation Matrix
local function mat3_create_rotatex(res, angle)
	local c = math.cos(angle)
	local s = math.sin(angle)

	mat3_assign(res, mat3_identity)

	res[1][1] = c;	res[1][2] = -s
	res[2][1] = s;	res[2][2] = c

	return res
end

local function mat3_create_rotatex_new(angle)
	return mat3_create_rotatex(mat3(), angle)
end

local function mat3_create_rotatey(res, angle)
	local c = math.cos(angle)
	local s = math.sin(angle)

	mat3_assign(res, mat3_identity)

	res[0][0] = c;	res[0][2] = s
	res[2][0] = -s;	res[2][2] = c

	return res
end

local function mat3_create_rotatey_new(angle)
	return mat3_create_rotatey(mat3(), angle)
end


local function mat3_create_rotatez(res, angle)
	local c = math.cos(angle)
	local s = math.sin(angle)

	mat3_assign(res, mat3_identity)

	res[0][0] = c;	res[0][1] = -s
	res[1][0] = s;	res[1][1] = c

	return res
end

local function mat3_create_rotatez_new(angle)
	return mat3_create_rotatez(mat3(), angle)
end


local function mat3_axis_angle_rotation(res, angle, x, y, z)
    local c = math.cos(angle)
	local s = math.sin(angle);
    local t = 1.0 - c;

    local nAxis = Vec3.Normalize(vec3(x,y,z));

    -- intermediate values
    local tx = t*nAxis[0];
	local ty = t*nAxis[1];
	local tz = t*nAxis[2];

    local sx = s*nAxis[0];
	local sy = s*nAxis[1];
	local sz = s*nAxis[2];

    local txy = tx*nAxis[1];
	local tyz = tx*nAxis[2];
	local txz = tx*nAxis[2];

    -- set matrix
    res[0][0] = tx*nAxis[0] + c;
    res[0][1] = txy - sz;
    res[0][2] = txz + sy;

    res[1][0] = txy + sz;
    res[1][1] = ty*nAxis[1] + c;
    res[1][2] = tyz - sx;

    res[2][0] = txz - sy;
    res[2][1] = tyz + sx;
    res[2][2] = tz*nAxis[2] + c;

    return res;
end

local function mat3_axis_angle_rotation_new(angle, x, y, z)
	return mat3_axis_angle_rotation(mat3(), angle, x, y, z)
end


--[[
local function mat3_create_rotation(res, angle, x, y, z)
	local mag = math.sqrt(x*x+y*y+z*z)
	local s = math.sin(angle)
	local c = math.cos(angle)

	if mag == 0 then
		mat3_assign(res, mat3_identity)
		return res
	end

	mag = 1/mag

	-- Rotation matrix is normalized
	x = x * mag
	y = y * mag
	z = z * mag

	local xx = x * x
	local yy = y * y
	local zz = z * z
	local xy = x * y
	local yz = y * z
	local zx = z * x
	local xs = y * s
	local ys = y * s
	local zs = z * s

	local one_c = 1 - c;

	res[0][0] =(one_c*xx) + c
	res[0][1] =(one_c*xy) - zs
	res[0][2] =(one_c*zx) + ys

	res[1][0] =(one_c*xy) + zs
	res[1][1] =(one_c*yy) + c
	res[1][2] =(one_c*yz) - xs

	res[2][0] =(one_c*zx) -ys
	res[2][1] =(one_c*yz) +xs
	res[2][2] =(one_c*zz) + c

	return res
end

local function mat3_create_rotation_new(angle, x, y, z)
	return mat3_create_rotation(mat3(), angle, x, y, z)
end
--]]


-- Transform a Point
local function mat3_mul_vec3(res, m, v)
	res[0] = m[0][0]*v[0] + m[0][1]*v[1] + m[0][2]*v[2]
	res[1] = m[1][0]*v[0] + m[1][1]*v[1] + m[1][2]*v[2]
	res[2] = m[2][0]*v[0] + m[2][1]*v[1] + m[2][2]*v[2]

	return res
end

local function mat3_mul_vec3_new(m, v)
	return mat3_mul_vec3(vec3(), m, v)
end





local function mat3_tostring(m)
	res={}

	table.insert(res,'{\n')
	for row = 0,2 do
		table.insert(res,'{')
		for col = 0,2 do
			table.insert(res,m[row][col])
			if col < 2 then
				table.insert(res,',')
			end
		end
		table.insert(res,'}')
		if row < 2 then
			table.insert(res, ',\n')
		end
	end
	table.insert(res, '}\n')

	return table.concat(res)
end

function mat3_is_zero(m)
	return SquareMatrix.IsZero(m,3)
end



Mat3 = {
	new = mat3_new,
	Clone = mat3_clone,
	Assign = mat3_assign,
	Clean = function(m) return SquareMatrix.Clean(m,3) end,

	Identity = mat3_identity,
	GetColumn = mat3_get_col,
	SetColumn = mat3_set_col,

	GetRow = mat3_get_row,
	SetRow = mat3_set_row,
	SetRows = mat3_set_rows,

	GetDiagonal = mat3_get_diagonal_new,

	Inverse = mat3_inverse_new,
	Transpose = mat3_transpose_new,

	Mul = mat3_mul_mat3_new,
	MulVec3 = mat3_mul_vec3_new,

	CreateRotation = mat3_axis_angle_rotation_new,
	CreateRotateX = mat3_create_rotatex_new,
	CreateRotateY = mat3_create_rotatey_new,
	CreateRotateZ = mat3_create_rotatez_new,


	CreateScale = mat3_create_scale_new,
	CreateTranslation = mat3_create_translation_new,

	TransformNormal = mat3_transform_vec_new,

	IsIdentity = mat_is_identity,
	IsZero = mat3_is_zero,

	tostring = mat3_tostring,
}

