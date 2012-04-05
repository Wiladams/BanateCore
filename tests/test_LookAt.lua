-- Put this at the top of any test
local ppath = package.path..';..\\?.lua;..\\out\\?.lua'
package.path = ppath;

require "matrix"

function LookAt(eye, lookAt, up)
	local viewDir = Vec3.Sub(lookAt, eye)
	local viewSide = nil
	local viewUp = nil

print(Vec3.tostring(eye), Vec3.tostring(lookAt), Vec3.tostring(up))

	viewDir = Vec3.Normalize(viewDir)

print("View Direction Normalized: ", Vec3.tostring(viewDir))

	viewUp = up - Vec3.Mul(Vec3.Dot(up,viewDir),viewDir)
	viewUp = Vec3.Normalize(viewUp)
	viewSide = Vec3.Cross(viewDir,viewUp)


end


--LookAt(vec3(0,0,10), vec3(0,0,0), vec3(0,1,0))

function CloseEnough(fCandidate, fCompare, fEpsilon)
    return (math.abs(fCandidate - fCompare) < fEpsilon);
end

function ProjectXYZ(vPointOut, mModelView, mProjection, iViewPort, vPointIn)

	vBack = vec4(vPointIn[0], vPointIn[1], vPointIn[2], 1)

	vForth = Mat4.TransformPoint(mModelView, vBack)
	vBack = Mat4.TransformPoint(mProjection, vForth)

    if not CloseEnough(vBack[3], 0.0, 0.000001) then
        local div = 1.0 / vBack[3];
        vBack[0] = vBack[0] * div;
        vBack[1] = vBack[1] * div;
        vBack[2] = vBack[2] * div;
	end

    vPointOut[0] = iViewPort[0]+(1.0+(vBack[0]))*(iViewPort[2])/2.0;
    vPointOut[1] = iViewPort[1]+(1.0+(vBack[1]))*(iViewPort[3])/2.0;

	if(iViewPort[0] ~= 0)	then
		vPointOut[0] = vPointOut[0] - (iViewPort[0]);
	end

	if(iViewPort[1] ~= 0) then
		vPointOut[1] = vPointOut[1] - (iViewPort[1]);
	end

 	vPointOut[2] = vBack[2];

	return vPointOut
end


-- setup model view matrix
local mvm = Mat4.Clone(Mat4.Identity)

-- setup projection matrix
local prjm = Mat4.CreatePerspective(35, 640/480, 1, 1000)

-- setup viewport
local viewPort = vec4(0,0,640,480)

-- setup the point to TransformPoint
local ptin = vec3(5,5,0)

-- transform
local opt = vec3()
local tpt = ProjectXYZ(opt, mvm, prjm, viewPort, ptin)

print(Vec3.tostring(opt))
print(Vec3.tostring(tpt))
