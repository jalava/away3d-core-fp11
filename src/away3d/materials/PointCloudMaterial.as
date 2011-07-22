package away3d.materials
{
	import flash.geom.Matrix;
	import away3d.materials.passes.PointCloudPass;
	import away3d.core.managers.Texture3DProxy;
	import flash.display.BitmapData;
	/**
	 * @author jalava
	 */
	public class PointCloudMaterial extends MaterialBase
	{
		public var _particlePass:PointCloudPass;
		
		private var _particleMap:BitmapData;
		public var _particleTexture:Texture3DProxy;
		private var _particleScale:Number;
		public function PointCloudMaterial(particleMap:BitmapData, particleScale:Number) {
			this._particleScale = particleScale;
			this._particleMap = particleMap;
			_particleTexture = new Texture3DProxy();
			addPass(_particlePass = new PointCloudPass(_particleScale));			
			resetParticleTexture();
		}
		
		public function set particleMap(value : BitmapData) : void {
			this._particleMap = value;	
			resetParticleTexture();
		}
		
		public function get particleMap() : BitmapData {
			return _particleMap;
		}
				
		public function resetParticleTexture():void
		{
			var targetBitmap:BitmapData = new BitmapData(128, 128, true, 0);
			var mat:Matrix = new Matrix();
			mat.identity();
			mat.translate(-_particleMap.width/2, -_particleMap.height/2);
			mat.scale(128/_particleMap.width, 128/_particleMap.height);
			mat.translate(64, 64);
			targetBitmap.draw(_particleMap, mat, null, null, null, true);	
			_particleTexture.bitmapData = targetBitmap;
			_particlePass.particleTexture = _particleTexture;
		}

		override public function dispose(deep : Boolean) : void
		{
			super.dispose(deep);
			if(deep && _particleMap)
			{
				_particleMap.dispose();
			}			
			_particleTexture.dispose(deep);
		}
	}
}
