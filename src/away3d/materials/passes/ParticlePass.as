package away3d.materials.passes
{
	import flash.utils.getTimer;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Matrix3D;
	import away3d.entities.particles.ParticleSubMesh;
	import away3d.entities.particles.ParticleSubGeometry;
	import flash.display3D.Context3DVertexBufferFormat;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.managers.Texture3DProxy;

	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import flash.display3D.Context3D;

	import away3d.cameras.Camera3D;
	import away3d.arcane;
	use namespace arcane;
	/**
	 * @author jalava
	 */
	public class ParticlePass extends MaterialPassBase
	{
		protected static const parCornersIdx:uint = 0;
		protected static const mat:uint = parCornersIdx+4;
		protected static const time:uint = mat+4;
		protected static const ZERO:uint = time+1;
		protected static const ONE:uint = ZERO+1;
		
		public var right:Vector3D = new Vector3D();
		public var up : Vector3D = new Vector3D();
		public var particleTexture:Texture3DProxy;
		
		public var cornersData:Vector.<Number> = new Vector.<Number>(16);
		public var timeVector:Vector.<Number> = new Vector.<Number>(4);
		
		protected static const ALPHA_KILL:uint = 0;		
		protected static const ALPHA_KILL_DATA:Vector.<Number> = Vector.<Number>([1,1,1,0.005]);
		protected static const ONE_DATA:Vector.<Number> = Vector.<Number>([1,1,1,1]);
		protected static const ZERO_DATA:Vector.<Number> = Vector.<Number>([0,0,0,0]);
		
		private var _partScale:Number = 1;
		
		private var _vertCode:String =
			// move by speed			
			// calculate time delta vt0.x = age = time-spawnTime;			
			"sub vt0.x, vc"+time+".x,va3.x\n"+
			// life left -> vt1.x = lifeLeft = life-age;
		//	"sub vt1.x, va3.y, vt0.x\n"+
			// (age/life) -> percent of life lived
			"div vt1.x, vt0.x, va3.y\n"+		
			// Clamp to 0..1	
			"max vt1.x, vc"+ZERO+".x, vt1.x \n"+
			"min vt1.x, vc"+ONE+".x, vt1.x\n"+
			//// 1-lifePe -> 
//			"sub vt1.x, vc"+ONE+".x, vt1.x\n"+
						
			// Vertex Alpha = startalpha-((end alpha - start alpha)*age%) 
			// vt2 = va3.w - va3.z = (end alpha - start alpha)
			"sub vt2.w,va3.w,va3.z\n"+
			// vt2 = vt2 * vt1.x (age%) 
			"mul vt2.w,vt2.w,vt1.x\n"+
			// vt2 = va3.z-v2
			"add vt2.w, va3.z , vt2.w \n"+
			"min vt2.w, vc"+ONE+".w, vt2.w\n"+
			"max vt2.w, vc"+ZERO+".w, vt2.w \n"+
			// Move particles
			"mul vt0, va4, vt0.xxxx \n"+
			"add vt0, vt0.xyz, va0 \n"+			
			// Expand corners			
/*			"add vt0, vt2, vc[va2.x]			\n" + */
			"add vt0, vt0, vc[va2.x]			\n" + 		
			// Offset to place 
		 	"m44 op, vt0, vc"+mat+"\n" +

			// Send color from stream 3
		//	"mov v0, va3							\n" +			
			// Texture UV 
			"mov v1, va1			  \n"+ 
			"mov vt2.xyz, vc"+ONE+".xyz \n"+			
			"mov v2, vt2 \n"+			
			"";
			
		// TODO: Particle fog
		private var _fragCode:String = "mov ft0, v1\n"+			
			"tex ft1, ft0, fs0 <2d,linear,clamp>\n"+
			"mul ft1.w, ft1.w, v2.w \n"+			
		//	"mul ft1, ft1, v0 \n"+			
			"mov oc, ft1\n";

		public function ParticlePass(partScale:Number) {

			super();
			_numUsedStreams = 3;
			_numUsedTextures = 1;
			_numUsedVertexConstants = 8;
			cornersData[3] = 1;
			cornersData[7] = 1;
			cornersData[11] = 1;
			cornersData[15] = 1;	
			_partScale = partScale;		
		}

		
		override arcane function getFragmentCode() : String
		{
			return _fragCode; 
		}
			
		override arcane function getVertexCode() : String
		{
			// Constants
			// vc0 - vc3 Particle corners
			// vc4 - vc7 Matrix 			 
			// Particle positioning from stream 0 with corner index in stream 3
			trace(_vertCode);
			return _vertCode;	// Offset to place
		}
		
		private var posMat:Matrix3D = new Matrix3D();
		
		override arcane function render(renderable : IRenderable, stage3DProxy : Stage3DProxy, camera : Camera3D) : void
		{		
			var context : Context3D = stage3DProxy._context3D;
			stage3DProxy.setSimpleVertexBuffer(0, renderable.getVertexBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_3);
			stage3DProxy.setSimpleVertexBuffer(1, renderable.getUVBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_2);
			stage3DProxy.setSimpleVertexBuffer(2, (renderable as ParticleSubMesh).getVertexCornerBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_1);
			stage3DProxy.setSimpleVertexBuffer(3, (renderable as ParticleSubMesh).getSpawnTimeBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_4);
			stage3DProxy.setSimpleVertexBuffer(4, (renderable as ParticleSubMesh).getSpeedBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_3);
			
			context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
			context.setDepthTest(false, Context3DCompareMode.LESS_EQUAL);			
			context.setCulling(Context3DTriangleFace.BACK);
			context.drawTriangles(renderable.getIndexBuffer(stage3DProxy), 0, renderable.numTriangles);
			posMat.copyFrom(renderable.sceneTransform);
			posMat.append(camera.inverseSceneTransform);
			var rawData:Vector.<Number> = posMat.rawData;
			
			var scale:Number = _partScale;
			right.x = rawData[0]*scale; right.y = rawData[4]*scale; right.z = rawData[8]*scale;
			up.x = rawData[1]*scale; up.y = rawData[5]*scale; up.z = rawData[9]*scale;
			cornersData[0] =  -right.x - up.x; cornersData[1] = -right.y - up.y; cornersData[2] = -right.z - up.z;
			cornersData[4] =  right.x - up.x; cornersData[5] = right.y - up.y; cornersData[6] = right.z - up.z;
			cornersData[8] =  right.x + up.x; cornersData[9] = right.y + up.y; cornersData[10] = right.z + up.z;
			cornersData[12] =  -right.x + up.x; cornersData[13] = -right.y + up.y; cornersData[14] = -right.z + up.z;
			cornersData[3] = 1;
			cornersData[7] = 1;
			cornersData[11] = 1;
			cornersData[15] = 1;
			timeVector[1] = timeVector[2] = timeVector[3] =timeVector[0] = getTimer();
		//trace(timeVector);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, mat, renderable.modelViewProjection, true);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, parCornersIdx, cornersData, 4);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, time, timeVector , 1);								
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, ZERO, ZERO_DATA, 1);								
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, ONE, ONE_DATA, 1);								
						
		//	super.render(renderable, stage3DProxy, camera);
		}
		
		override arcane function activate(stage3DProxy : Stage3DProxy, camera : Camera3D) : void
		{
		//	trace("Particle Activate");
			super.activate(stage3DProxy, camera);

			stage3DProxy.setTextureAt(0, particleTexture.getTextureForStage3D(stage3DProxy));
		}

		override arcane function deactivate(stage3DProxy : Stage3DProxy) : void
		{
		//	trace("Particle deactivate");
			super.deactivate(stage3DProxy);
		}

	}
}
