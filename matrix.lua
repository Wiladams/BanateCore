require "000"


local vec = require "vec_func"

local realv = floatv

-- Row ordering of elements
local m4r = {
	{0,1,2,3},
	{4,5,6,7},
	{8,9,10,11},
	{12,13,14,15}
}

-- Column ordering of elements
local m4c = {
	{0,4,8,12},
	{1,5,9,13},
	{2,6,10,14},
	{3,7,11,15}
}

local mc400 = 0
local mc401 = 4
local mc402 = 8
local mc403 = 12

local mc410 = 1
local mc411 = 5
local mc412 = 9
local mc413 = 13

local mc420 = 2
local mc421 = 6
local mc422 = 10
local mc423 = 14

local mc430 = 3
local mc431 = 7
local mc432 = 11
local mc433 = 15


-- Identity matrix for a 4x4 matrix
mat4_identity =  realv(16,1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)


function mat4_new(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p)
	a = a or 0
	b = b or 0
	c = c or 0
	d = d or 0

	e = e or 0
	f = f or 0
	g = g or 0
	h = h or 0

	i = i or 0
	j = j or 0
	k = k or 0
	l = l or 0

	m = m or 0
	n = n or 0
	o = o or 0
	p = p or 0

	return realv(16,a,b,c,d, e,f,g,h, i,j,k,l, m,n,o,p)
end


local function mat4_getoffset(row,col,roworder)
	if not roworder then
		-- column order
		return col*4 + row
	else
		-- row order
		return row*4 + col
	end
end

local function mat4_get(m, row, col, roworder)
	return m[mat4_getoffset(row,col,roworder)]
end

local function mat4_set(m, row, col, value, roworder)
	m[mat4_getoffset(row,col,roworder)] = value
	return m
end

local function mat4_clone(m)

	local res = mat4_new(
		m[0],m[1],m[2],m[3],
		m[4],m[5],m[6],m[7],
		m[8],m[9],m[10],m[11],
		m[12],m[13],m[14],m[15])

	return res
end

local function mat4_assign(a, b)
	for i=0,15 do
		a[i] = b[i]
	end
end

local function mat4_get_col(m, col, roworder)
	local res = realv(4)
	res[0] = mat4_get(m, 0,col, roworder)
	res[1] = mat4_get(m, 1,col, roworder)
	res[2] = mat4_get(m, 2,col, roworder)
	res[3] = mat4_get(m, 3,col, roworder)

	return res
end

local function mat4_set_col(m, col, vec, roworder)
	mat4_set(m, 0, col, vec[0], roworder)
	mat4_set(m, 1, col, vec[0], roworder)
	mat4_set(m, 2, col, vec[0], roworder)
	mat4_set(m, 3, col, vec[0], roworder)

	return m
end


local function mat4_get_row(m, row, roworder)
	local res = realv(4)

	res[0] = mat4_get(m, row,0,roworder)
	res[1] = mat4_get(m, row,1,roworder)
	res[2] = mat4_get(m, row,2,roworder)
	res[3] = mat4_get(m, row,3,roworder)

	return res
end

local function mat4_set_row(m, row, vec, roworder)
	mat4_set(m, row, 0, vec[0], roworder)
	mat4_set(m, row, 1, vec[0], roworder)
	mat4_set(m, row, 2, vec[0], roworder)
	mat4_set(m, row, 3, vec[0], roworder)

	return m
end

-- Matrix Multiplication
local function mat4_mul_mat4(res, a, b, roworder)
	function A(row,col)
		return mat4_get(a, row, col, roworder)
	end

	function B(row,col)
		return mat4_get(b, row, col, roworder)
	end

	function PS(row,col, value)
		mat4_set(res, row, col, value, roworder)
	end

	for i = 0,3 do
		local ai0=A(i,0);
		local ai1=A(i,1);
		local ai2=A(i,2);
		local ai3=A(i,3);

		PS(i,0, ai0 * B(0,0) + ai1 * B(1,0) + ai2 * B(2,0) + ai3 * B(3,0));
		PS(i,1, ai0 * B(0,1) + ai1 * B(1,1) + ai2 * B(2,1) + ai3 * B(3,1));
		PS(i,2, ai0 * B(0,2) + ai1 * B(1,2) + ai2 * B(2,2) + ai3 * B(3,2));
		PS(i,3, ai0 * B(0,3) + ai1 * B(1,3) + ai2 * B(2,3) + ai3 * B(3,3));
	end

	return res
end

local function mat4_mul_mat4_new(a, b, roworder)
	return mat4_mul_mat4(mat4_new(), a, b, roworder)
end

local function mat4_get_diagonal(res, m)
	res[0] = m[mc400]
	res[1] = m[mc411]
	res[2] = m[mc422]
	res[3] = m[mc433]

	return res
end

local function mat4_get_diagonal_new(m)
	return mat4_get_diagonal(realv(4), m)
end



local function mat4_sub_determinant(m, i, j)
    local x, y, ii, jj;
    local ret;
	local m3 = realv(9);

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


function mat4_inverse(mInverse, m)

    local i, j;
    local det =0
	local detij;

    -- First, calculate the sub determinant
    for i = 0,3 do
		local subdet = 0
		if band(i,0x1) > 0 then
			subdet = (-m[i] * mat4_sub_determinant(m, 0, i))
		else
			subdet = (m[i] * mat4_sub_determinant(m, 0,i))
		end

		det = det + subdet
	end

    det = 1 / det;

    -- calculate inverse
    for i = 0,3  do
        for j = 0,3 do
            detij = mat4_sub_determinant(m, j, i);
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

function mat4_inverse_new(m)
	return mat4_inverse(mat4_new(), m)
end

--[[
		TRANSFORMATION  MATRICES
--]]
-- Matrix creation
local function mat4_create_scale(res, x, y, z)
	mat4_assign(res, mat4_identity)

	mat4_set(res, 0,0, x)
	mat4_set(res, 1,1, y)
	mat4_set(res, 2,2, z)

	return res
end

local function mat4_create_scale_new(x,y,z)
	return mat4_create_scale(mat4_new(), x, y, z)
end

-- Create Translation Matrix
local function mat4_create_translation(res, x, y, z)
	mat4_assign(res, mat4_identity)

	mat4_set(res, 0, 3, x)
	mat4_set(res, 1, 3, y)
	mat4_set(res, 2, 3, z)

	return res
end

local function mat4_create_translation_new(x,y,z)
	return mat4_create_translation(mat4_new(), x, y, z)
end


-- Create Rotation Matrix
local function mat4_create_rotation(res, angle, x, y, z)
	local mag = 1/math.sqrt(x*x+y*y+z*z)
	local s = math.sin(angle)
	local c = math.cos(angle)

	mat4_assign(res, mat4_identity)

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

	mat4_set(res, 0,0, (one_c*xx) + c)
	mat4_set(res, 0,1, (one_c*xy) - zs)
	mat4_set(res, 0,2, (one_c*zx) + ys)
	mat4_set(res, 0,3, 0)

	mat4_set(res, 1,0, (one_c*xy) + zs)
	mat4_set(res, 1,1, (one_c*yy) + c)
	mat4_set(res, 1,2, (one_c*yz) - xs)
	mat4_set(res, 1,3, 0)

	mat4_set(res, 2,0, (one_c*zx) -ys)
	mat4_set(res, 2,1, (one_c*yz) +xs)
	mat4_set(res, 2,2, (one_c*zz) + c)
	mat4_set(res, 2,3, 0)

	mat4_set(res, 3,0, 0)
	mat4_set(res, 3,1, 0)
	mat4_set(res, 3,2, 0)
	mat4_set(res, 3,3, 1)


	return res
end

local function mat4_create_rotation_new(angle, x, y, z)
	return mat4_create_rotation(mat4_new(), angle, x, y, z)
end


-- Transform a Point
-- Need to include the 'w'
local function mat4_transform_pt(res, m, pt)
	res[0] = m[mc400]*pt[0] + m[mc401]*pt[1] + m[mc402]*pt[2] + m[mc403]
	res[1] = m[mc410]*pt[0] + m[mc411]*pt[1] + m[mc412]*pt[2] + m[mc413]
	res[2] = m[mc420]*pt[0] + m[mc421]*pt[1] + m[mc422]*pt[2] + m[mc423]

	return res
end

local function mat4_transform_pt_new(m, pt)
	return mat4_transform_pt(realv(3), m, pt)
end

-- Transform a Vector
-- Need to ignore the 'w', as it is '0' for a vector
local function mat4_transform_vec(res, m, vec)
	res[0] = m[mc400]*vec[0] + m[mc401]*vec[1] + m[mc402]*vec[2]
	res[1] = m[mc410]*vec[0] + m[mc411]*vec[1] + m[mc412]*vec[2]
	res[2] = m[mc420]*vec[0] + m[mc421]*vec[1] + m[mc422]*vec[2]

	return res
end

local function mat4_transform_vec_new(m, vec)
	return mat4_transform_pt(realv(3), m, vec)
end



local function vec4_tostring(v)
	res={}

	table.insert(res,'{')
	for col = 0,3 do
		table.insert(res,v[col])
		if col < 3 then
			table.insert(res,',')
		end
	end
	table.insert(res,'}')

	return table.concat(res)
end

local function mat4_tostring(m, roworder)
	res={}

	table.insert(res,'{')
	for row = 0,3 do
		table.insert(res,'{')
		for col = 0,3 do
			table.insert(res,mat4_get(m, row,col))
			if col < 3 then
				table.insert(res,',')
			end
		end
		table.insert(res,'}')
		if row < 3 then
			table.insert(res, ',\n')
		end
	end
	table.insert(res, '}')

	return table.concat(res)
end

Mat4 = {
	new = mat4_new,
	Clone = mat4_clone,
	Assign = mat4_assign,

	Identity = mat4_identity,
	GetColumn = mat4_get_col,
	SetColumn = mat4_set_col,

	GetRow = mat4_get_row,
	SetRow = mat4_set_row,

	GetDiagonal = mat4_get_diagonal_new,

	Multiply = mat4_mul_mat4_new,
	Inverse = mat4_inverse_new,

	CreateRotation = mat4_create_rotation_new,
	CreateScale = mat4_create_scale_new,
	CreateTranslation = mat4_create_translation_new,

	TransformPoint = mat4_transform_pt_new,
	TransformNormal = mat4_transform_vec_new,

	vec4_tostring = vec4_tostring,
	tostring = mat4_tostring,
}
