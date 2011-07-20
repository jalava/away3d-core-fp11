package away3d.entities.particles
{
	import away3d.core.managers.Stage3DProxy;
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Vector3D;

	import away3d.core.base.SubGeometry;
	import away3d.arcane;
	
	use namespace arcane;
	
	/**
	 * @author jalava
	 */
	public class ParticleSubGeometry extends SubGeometry
	{
		private var _particlesPerBatch:int;
		
		private var _spawnTimers:Vector.<Number>;
		private var _spawnTimersDirty:Vector.<Boolean> = new Vector.<Boolean>(8);
		private var _spawnTimerBuffers:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
		
		private var _vertexSpeedData:Vector.<Number>;
		private var _vertexSpeedBufferDirty:Vector.<Boolean> = new Vector.<Boolean>(8);
		private var _vertexSpeedBuffers:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
		
		private var _vertexCornerIndices:Vector.<Number>;
		private var _vertexCornerBufferDirty:Vector.<Boolean> = new Vector.<Boolean>(8);
		private var _vertexCornerBuffers:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
		
		public var spawnIndex:int; // Last spawn index, these rotate automatically on top of itself
		public var oldestSpawn:uint; // This is compared to decide which sub geometry gets next spawn
		
		public function ParticleSubGeometry(particlesPerBatch:int)
		{
			this._particlesPerBatch = particlesPerBatch;
			var uvData:Vector.<Number>   = Vector.<Number>([.0, .0,		1.0, .0, 	1.0, 1.0,	.0, 1.0]);
//			var indexData:Vector.<uint> = Vector.<uint>([0, 1, 2, 0, 2, 3]);
			var indexData:Vector.<uint> = Vector.<uint>([3, 1, 0, 3, 2, 1]);
			var vertTanData:Vector.<Number> = Vector.<Number>([1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0]);
			var vertNormalData:Vector.<Number> = Vector.<Number>([.0, .0, -1.0, .0, .0, -1.0, .0, .0, -1.0, .0, .0, -1.0]);
			var vertCornerData:Vector.<Number> = Vector.<Number>([0,1,2,3]);
			var bufferVertData:Vector.<Number> = new Vector.<Number>();
			var bufferUvData:Vector.<Number> = new Vector.<Number>();
			var bufferIndexData:Vector.<uint> = new Vector.<uint>();
			var bufferVertTanData:Vector.<Number> = new Vector.<Number>();
			var bufferVertNormalData:Vector.<Number> = new Vector.<Number>();
			var bufferCornerIndexData:Vector.<Number> = new Vector.<Number>();
			_spawnTimers = new Vector.<Number>(_particlesPerBatch);
			_vertexSpeedData = new Vector.<Number>(_particlesPerBatch*4);
			var i:int = 0;
			for(i = 0;i<this._particlesPerBatch;i++) {
				var x:Number = Math.random()*10-5;
				var y:Number = Math.random()*10-5;
				var z:Number = Math.random()*10-5;
				var vertData:Vector.<Number> = Vector.<Number>([x, y, z,	x, y, z,  	x, y, z, 	x, y, z]);
				bufferVertData = bufferVertData.concat(vertData);
				bufferUvData = bufferUvData.concat(uvData);
				bufferIndexData = bufferIndexData.concat(indexData);
				bufferVertTanData = bufferVertTanData.concat(vertTanData);
				bufferVertNormalData = bufferVertNormalData.concat(vertNormalData);
				bufferCornerIndexData = bufferCornerIndexData.concat(vertCornerData);
				_spawnTimers[i] = -1;
				_vertexSpeedData[i*4] = 0;
				_vertexSpeedData[i*4+1] = 0;
				_vertexSpeedData[i*4+2] = 0;
				_vertexSpeedData[i*4+3] = 0;
			}
			_vertexCornerIndices = bufferCornerIndexData;
			updateVertexData(bufferVertData);
			updateUVData(bufferUvData);
			updateIndexData(bufferIndexData);
			updateVertexTangentData(bufferVertTanData);
			updateVertexNormalData(bufferVertNormalData);
			trace("UPDATED!");
		}
		
		public function getSpawnTimerBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D
		{
			var contextIndex : int = stage3DProxy._stage3DIndex;
			if (contextIndex > _maxIndex) _maxIndex = contextIndex;

			if (!_listeningForDispose[contextIndex]) initDisposeListener(stage3DProxy);

			if (_spawnTimersDirty[contextIndex] || !_spawnTimerBuffers[contextIndex]) {
				VertexBuffer3D(_spawnTimerBuffers[contextIndex] ||= stage3DProxy._context3D.createVertexBuffer(_numVertices, 1)).uploadFromVector(_spawnTimers, 0, _numVertices);
				_spawnTimersDirty[contextIndex] = false;
			}

			return _spawnTimerBuffers[contextIndex];			
		}
		
		public function getParticleSpeedBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D {
			var contextIndex : int = stage3DProxy._stage3DIndex;
			if (contextIndex > _maxIndex) _maxIndex = contextIndex;

			if (!_listeningForDispose[contextIndex]) initDisposeListener(stage3DProxy);

			if (_vertexSpeedBufferDirty[contextIndex] || !_vertexSpeedBuffers[contextIndex]) {
				VertexBuffer3D(_vertexSpeedBuffers[contextIndex] ||= stage3DProxy._context3D.createVertexBuffer(_numVertices, 4)).uploadFromVector(_vertexSpeedData, 0, _numVertices);
				_vertexSpeedBufferDirty[contextIndex] = false;
			}

			return _vertexSpeedBuffers[contextIndex];			
		}
		
		public function getVertexCornerBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D {
			var contextIndex : int = stage3DProxy._stage3DIndex;
			if (contextIndex > _maxIndex) _maxIndex = contextIndex;

			if (!_listeningForDispose[contextIndex]) initDisposeListener(stage3DProxy);

			if (_vertexCornerBufferDirty[contextIndex] || !_vertexCornerBuffers[contextIndex]) {
				VertexBuffer3D(_vertexCornerBuffers[contextIndex] ||= stage3DProxy._context3D.createVertexBuffer(_numVertices, 1)).uploadFromVector(_vertexCornerIndices, 0, _numVertices);
				_vertexCornerBufferDirty[contextIndex] = false;
			}

			return _vertexCornerBuffers[contextIndex];			
		}
				
		
		public function spawnParticle(xPos:Number = 0, yPos:Number = 0, zPos:Number = 0, xSpeed:Number = 0, ySpeed:Number = 0, zSpeed:Number = 0):void
		{
			invalidateBuffers(_spawnTimersDirty);
			invalidateBuffers(_vertexSpeedBufferDirty);
			
		}
	}
}
