package away3d.materials.passes
{
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

		
		public var right:Vector3D = new Vector3D();
		public var up : Vector3D = new Vector3D();
		public var particleTexture:Texture3DProxy;
		
		public var cornersData:Vector.<Number> = new Vector.<Number>(16);
		public var partSizesData:Vector.<Number> = new Vector.<Number>(4);
		
		protected static const ALPHA_KILL:uint = 0;		
		protected static const ALPHA_KILL_DATA:Vector.<Number> = Vector.<Number>([1,1,1,0.005]);
		protected static const ONE_DATA:Vector.<Number> = Vector.<Number>([1,1,1,1]);
		protected static const ZERO_DATA:Vector.<Number> = Vector.<Number>([0,0,0,0]);
		
		private var _vertCode:String =
/*			// Offset to place 
		 	"m44 vt0, va0, vc"+mat+"\n" +
			// Expand corners
			"add op, vt0, vc[va2.x]			\n" +		
*/
			// Expand corners
			"add vt0, va0, vc[va2.x]			\n" +		
			// Offset to place 
		 	"m44 op, vt0, vc"+mat+"\n" +

			// Send color from stream 3
		//	"mov v0, va3							\n" +			
			// Texture UV 
			"mov v1, va1			  \n"+ 
			"";
			
		private var _fragCode:String = "mov ft0, v1\n"+			
			"tex ft1, ft0, fs0 <2d,linear,clamp>\n"+			
		//	"mul ft1, ft1, v0 \n"+			
			"mov oc, ft1\n";

		public function ParticlePass() {

			super();
			_numUsedStreams = 3;
			_numUsedTextures = 1;
			_numUsedVertexConstants = 8;
			cornersData[3] = 1;
			cornersData[7] = 1;
			cornersData[11] = 1;
			cornersData[15] = 1;			
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
			return _vertCode	// Offset to place
		}
		
		private var posMat:Matrix3D = new Matrix3D();
		
		override arcane function render(renderable : IRenderable, stage3DProxy : Stage3DProxy, camera : Camera3D) : void
		{		
			var context : Context3D = stage3DProxy._context3D;
			stage3DProxy.setSimpleVertexBuffer(0, renderable.getVertexBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_3);
			stage3DProxy.setSimpleVertexBuffer(1, renderable.getUVBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_2);
			stage3DProxy.setSimpleVertexBuffer(2, (renderable as ParticleSubMesh).getVertexCornerBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_1);

			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, mat, renderable.modelViewProjection, true);
//			context.setCulling(Context3DTriangleFace.NONE);
			context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
			context.setDepthTest(false, Context3DCompareMode.LESS_EQUAL);
			context.setCulling(Context3DTriangleFace.BACK);
//			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
//			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, renderable.modelViewProjection, true);
		//	trace("Rendering:"+renderable.numTriangles);
			context.drawTriangles(renderable.getIndexBuffer(stage3DProxy), 0, renderable.numTriangles);
			
			posMat.copyFrom(renderable.sceneTransform);
			posMat.append(camera.inverseSceneTransform);
			
			var rawData:Vector.<Number> = posMat.rawData;
			
			var scale:Number = 1.5;
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
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, parCornersIdx, cornersData, 4);								
						
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
