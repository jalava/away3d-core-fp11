package away3d.materials
{
	import away3d.core.managers.Texture3DProxy;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.display.BitmapData;
	import away3d.materials.passes.ParticlePass;
	/**
	 * @author jalava
	 */
	public class ParticleMaterial extends MaterialBase
	{
		private var _particlePass:ParticlePass;
		
		private var _particleMap:BitmapData;
		private var _particleTexture:Texture3DProxy;
		
		public function ParticleMaterial(particleMap:BitmapData, blurs:int = 8, sizes:int = 16, max_blur:int = 16) {
			this._particleMap = particleMap;
			_particleTexture = new Texture3DProxy();
			addPass(_particlePass = new ParticlePass());			
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
