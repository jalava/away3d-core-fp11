package away3d.materials.passes
{
	import M2D.sprites.Asset;
	import away3d.entities.particles.PointCloudSubGeometry;
	import flash.utils.getTimer;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DBlendFactor;
	import away3d.entities.particles.PointCloudSubMesh;
	import flash.display3D.Context3DVertexBufferFormat;
	import away3d.core.managers.Stage3DProxy;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import away3d.core.managers.Texture3DProxy;
	import away3d.arcane;
	
	use namespace arcane;
		
	/**
	 * @author jalava
	 */
	public class PointCloudPass extends MaterialPassBase
	{
		protected static const parCornersIdx:uint = 0;
		protected static const mat:uint = parCornersIdx+4;
		protected static const ZERO:uint = mat+4;
		protected static const ONE:uint = ZERO+1;
		protected static const sinVal:uint = ONE+1;
		
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
		private var _enc : Vector.<Number>;
		
		private var _vertCode:String =
			// Get corner offsets
			"mov vt1, vc[va2.x] \n"+
			// Scale the particle corners from particle size in va3.x
			"sat vt2, va3 \n"+
			"mul vt1.xyz, vt1.xyz, vt2.xxx \n"+					
			"add vt0, va0, vt1			\n" +
			// Offset to place 
		 	"m44 op, vt0, vc"+mat+"\n" +			
			// Texture UV 
			"mov v1, va1			  \n"+
			// Color
			"mov v2, vc"+ONE+"\n"+
			"mov v2.xyz, vt2.yzw \n"+
			"";
			

		private var _fragCode:String = "mov ft0, v1\n"+			
			"tex ft1, ft0, fs0 <2d,linear,clamp>\n"+
			// Color
			"mul ft1.xyz, ft1.xyz, v2.xyz \n"+
			"mov oc, ft1\n";

		public var dir:uint = 0;

		public function PointCloudPass(partScale:Number) {
			super();
			_numUsedStreams = 3;
			_numUsedTextures = 1;
			_numUsedVertexConstants = 8;
			cornersData[3] = 1;
			cornersData[7] = 1;
			cornersData[11] = 1;
			cornersData[15] = 1;	
			_partScale = partScale;		
			_enc = Vector.<Number>([	1.0, 255.0, 65025.0, 16581375.0,
							1.0 / 255.0, 1.0 / 255.0, 1.0 / 255.0,0.0]);
			
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
		private var direction:Vector3D = new Vector3D();
		private var lastDir:int = -1;
		private var sinValData:Vector.<Number> = new Vector.<Number>(4);
		override arcane function render(renderable : IRenderable, stage3DProxy : Stage3DProxy, camera : Camera3D) : void
		{		
			var pointCloud:PointCloudSubMesh = renderable as PointCloudSubMesh;
			var context : Context3D = stage3DProxy._context3D;
			stage3DProxy.setSimpleVertexBuffer(0, renderable.getVertexBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_3);
			stage3DProxy.setSimpleVertexBuffer(1, renderable.getUVBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_2);
			stage3DProxy.setSimpleVertexBuffer(2, pointCloud.getVertexCornerBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_1);
			stage3DProxy.setSimpleVertexBuffer(3, pointCloud.getParticleDataBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_4);
			
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);			
			context.setCulling(Context3DTriangleFace.BACK);
			this.direction.copyFrom(camera.scenePosition);
			//pointCloud.parentMesh.			
			this.direction = pointCloud.inverseSceneTransform.transformVector(this.direction);
			this.direction.normalize();
			
			//var dir:uint = calcOrder(direction);
			var dir:uint = this.dir; 
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
			sinValData[0] = 1;
			sinValData[1] = 0.43;
			sinValData[2] = 0.23;
			sinValData[3] = 0.58;
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, mat, renderable.modelViewProjection, true);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, parCornersIdx, cornersData, 4);										
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, ZERO, ZERO_DATA, 1);								
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, ONE, ONE_DATA, 1);								
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, sinVal, sinValData, 1);
			context.drawTriangles(pointCloud.getDirIndexBuffer(stage3DProxy,dir), 0, renderable.numTriangles);
		}
		
		public function calcOrder( dir:Vector3D ):uint
		{
		    var signs:uint;
		
		    const sx:uint = dir.x<0.0?1:0;
		    const sy:uint = dir.y<0.0?1:0;
		    const sz:uint = dir.z<0.0?1:0;
		    const ax:Number = Math.abs( dir.x );
		    const ay:Number = Math.abs( dir.y );
		    const az:Number = Math.abs( dir.z );
		
		    if( ax>ay && ax>az )
		        {
		        if( ay>az )
		            signs = 0 + ((sx<<2)|(sy<<1)|sz);
		        else
		            signs = 8 + ((sx<<2)|(sz<<1)|sy);
		        }
		    else if( ay>ax && ay>az )
		        {
		        if( ax>az )
		            signs = 16 + ((sy<<2)|(sx<<1)|sz);
		        else
		            signs = 24 + ((sy<<2)|(sz<<1)|sx);
		        }
		    else
		        {
		        if( ax>ay )
		            signs = 32 + ((sz<<2)|(sx<<1)|sy);
		        else
		            signs = 40 + ((sz<<2)|(sy<<1)|sz);
		        }
		
		    return signs;
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
