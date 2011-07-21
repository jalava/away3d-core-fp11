package away3d.entities.particles
{
	import flash.utils.getTimer;
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
		
		private var _particleData:Vector.<Number>;
		private var _particleDataDirty:Vector.<Boolean> = new Vector.<Boolean>(8);
		private var _particleDataBuffers:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
		
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
		//	var uvData:Vector.<Number>   = Vector.<Number>([.0, .0,		1.0, .0, 	1.0, 1.0,	.0, 1.0]);
			//var vertCornerData:Vector.<Number> = Vector.<Number>([0,1,2,3]);
			//var bufferVertData:Vector.<Number> = new Vector.<Number>();
			//var bufferUvData:Vector.<Number> = new Vector.<Number>();
			//var bufferIndexData:Vector.<uint> = new Vector.<uint>();
			//var bufferCornerIndexData:Vector.<Number> = new Vector.<Number>();
			_particleData = new Vector.<Number>(_particlesPerBatch*16, true);
			_vertexSpeedData = new Vector.<Number>(_particlesPerBatch*12, true);
			_vertexCornerIndices = new Vector.<Number>(_particlesPerBatch*4, true);
			//var vertData:Vector.<Number> = Vector.<Number>([0,0,0, 0,0,0, 0,0,0, 0,0,0]);
			var indexData:Vector.<uint> = new Vector.<uint>(_particlesPerBatch*6, true);
			var i:int = 0;
			var vertData:Vector.<Number> = new Vector.<Number>(_particlesPerBatch*12, true);
			var uvData:Vector.<Number> = new Vector.<Number>(_particlesPerBatch*8, true);
			//var time:uint = getTimer();
			for(i = 0;i<this._particlesPerBatch;i++) {
			/*	var xspeed:Number = Math.random()*1-.5;
				var yspeed:Number = Math.random()*1-.5;
				var zspeed:Number = Math.random()*1-.5;
				xspeed/=50;
				yspeed/=50;
				zspeed/=1000; */
			/*	var xspeed:Number = 0;
				var yspeed:Number = 0;
				var zspeed:Number = 0; */
				//var indexData:Vector.<uint> = Vector.<uint>([i*4+3, i*4+1, i*4+0, i*4+3, i*4+2, i*4+1]);
				vertData[i*12+0] = 0;
				vertData[i*12+0+1] = 0;
				vertData[i*12+0+2] = 0;
				vertData[i*12+3] = 0;
				vertData[i*12+3+1] = 0;
				vertData[i*12+3+2] = 0;
				vertData[i*12+6] = 0;
				vertData[i*12+6+1] = 0;
				vertData[i*12+6+2] = 0;
				vertData[i*12+9] = 0;
				vertData[i*12+9+1] = 0;
				vertData[i*12+9+2] = 0;		

				uvData[i*8+0] = 0;
				uvData[i*8+0+1] = 0;
				uvData[i*8+2] = 1;
				uvData[i*8+2+1] = 0;
				uvData[i*8+4] = 1;
				uvData[i*8+4+1] = 1;
				uvData[i*8+6] = 0;
				uvData[i*8+6+1] = 1;
				
				indexData[i*6+0] = i*4+3;
				indexData[i*6+1] = i*4+1;
				indexData[i*6+2] = i*4+0;
				indexData[i*6+3] = i*4+3;
				indexData[i*6+4] = i*4+2;
				indexData[i*6+5] = i*4+1;				
				
				_vertexCornerIndices[i*4+0] = 0;
				_vertexCornerIndices[i*4+1] = 1;
				_vertexCornerIndices[i*4+2] = 2;
				_vertexCornerIndices[i*4+3] = 3;				
				//bufferVertData = bufferVertData.concat(vertData);
				//bufferUvData = bufferUvData.concat(uvData);
				//bufferIndexData = bufferIndexData.concat(indexData);
				//bufferCornerIndexData = bufferCornerIndexData.concat(vertCornerData);
				// Time
				_particleData[i*16] = 0;
				_particleData[i*16+4] = 0;
				_particleData[i*16+8] = 0;
				_particleData[i*16+12] = 0;
				// Lifetime
				_particleData[i*16+1] = 1;
				_particleData[i*16+4+1] = 1;
				_particleData[i*16+8+1] = 1;
				_particleData[i*16+12+1] = 1;
				// Start Alpha
				_particleData[i*16+0+2] = 4;
				_particleData[i*16+4+2] = 4;
				_particleData[i*16+8+2] = 4;
				_particleData[i*16+12+2] = 4;
				// End Alpha
				_particleData[i*16+0+3] = 0;
				_particleData[i*16+4+3] = 0;
				_particleData[i*16+8+3] = 0;
				_particleData[i*16+12+3] = 0;
				
				_vertexSpeedData[i*12+0] = 0;
				_vertexSpeedData[i*12+0+1] = 0;
				_vertexSpeedData[i*12+0+2] = 0;
				_vertexSpeedData[i*12+3] = 0;
				_vertexSpeedData[i*12+3+1] = 0;
				_vertexSpeedData[i*12+3+2] = 0;
				_vertexSpeedData[i*12+6] = 0;
				_vertexSpeedData[i*12+6+1] = 0;
				_vertexSpeedData[i*12+6+2] = 0;
				_vertexSpeedData[i*12+9] = 0;
				_vertexSpeedData[i*12+9+1] = 0;
				_vertexSpeedData[i*12+9+2] = 0;
			}
		//	_vertexCornerIndices = bufferCornerIndexData;
			updateVertexData(vertData);
			updateUVData(uvData);
			updateIndexData(indexData);
			invalidateBuffers(_vertexCornerBufferDirty);
			oldestSpawn = getTimer();
			spawnIndex = 0;
			trace("UPDATED!");
		}
		
		public function getSpawnTimerBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D
		{
			var contextIndex : int = stage3DProxy._stage3DIndex;
			if (contextIndex > _maxIndex) _maxIndex = contextIndex;

			if (!_listeningForDispose[contextIndex]) initDisposeListener(stage3DProxy);

			if (_particleDataDirty[contextIndex] || !_particleDataBuffers[contextIndex]) {
				VertexBuffer3D(_particleDataBuffers[contextIndex] ||= stage3DProxy._context3D.createVertexBuffer(_numVertices, 4)).uploadFromVector(_particleData, 0, _numVertices);
				_particleDataDirty[contextIndex] = false;
			}

			return _particleDataBuffers[contextIndex];			
		}
		
		public function getParticleSpeedBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D {
			var contextIndex : int = stage3DProxy._stage3DIndex;
			if (contextIndex > _maxIndex) _maxIndex = contextIndex;

			if (!_listeningForDispose[contextIndex]) initDisposeListener(stage3DProxy);

			if (_vertexSpeedBufferDirty[contextIndex] || !_vertexSpeedBuffers[contextIndex]) {
				VertexBuffer3D(_vertexSpeedBuffers[contextIndex] ||= stage3DProxy._context3D.createVertexBuffer(_numVertices, 3)).uploadFromVector(_vertexSpeedData, 0, _numVertices);
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
				
		
		public function spawnParticle(xPos:Number = 0, yPos:Number = 0, zPos:Number = 0, xspeed:Number = 0, yspeed:Number = 0, zspeed:Number = 0, life:Number = 5000):void
		{
			var spawnTime:uint = getTimer();
			// Spawn time
			_particleData[spawnIndex*16] = spawnTime;
			_particleData[spawnIndex*16+4] = spawnTime;
			_particleData[spawnIndex*16+8] = spawnTime;
			_particleData[spawnIndex*16+12] = spawnTime;
			// Lifetime
			_particleData[spawnIndex*16+1] = life;
			_particleData[spawnIndex*16+1+4] = life;
			_particleData[spawnIndex*16+1+8] = life;
			_particleData[spawnIndex*16+1+12] = life;
			
			_vertices[spawnIndex*12] = xPos;
			_vertices[spawnIndex*12+3] = xPos;
			_vertices[spawnIndex*12+6] = xPos;
			_vertices[spawnIndex*12+9] = xPos;
			
			_vertices[spawnIndex*12+1] = yPos;
			_vertices[spawnIndex*12+1+3] = yPos;
			_vertices[spawnIndex*12+1+6] = yPos;
			_vertices[spawnIndex*12+1+9] = yPos;
			
			_vertices[spawnIndex*12+2] = zPos;
			_vertices[spawnIndex*12+2+3] = zPos;
			_vertices[spawnIndex*12+2+6] = zPos;
			_vertices[spawnIndex*12+2+9] = zPos;
			
			_vertexSpeedData[spawnIndex*12+0] = xspeed;
			_vertexSpeedData[spawnIndex*12+3] = xspeed;
			_vertexSpeedData[spawnIndex*12+6] = xspeed;
			_vertexSpeedData[spawnIndex*12+9] = xspeed;

			_vertexSpeedData[spawnIndex*12+0+1] = yspeed;
			_vertexSpeedData[spawnIndex*12+3+1] = yspeed;
			_vertexSpeedData[spawnIndex*12+6+1] = yspeed;
			_vertexSpeedData[spawnIndex*12+9+1] = yspeed;
			
			_vertexSpeedData[spawnIndex*12+0+2] = zspeed;
			_vertexSpeedData[spawnIndex*12+3+2] = zspeed;
			_vertexSpeedData[spawnIndex*12+6+2] = zspeed;
			_vertexSpeedData[spawnIndex*12+9+2] = zspeed;
			
			spawnIndex++;			
			if(spawnIndex >= _particlesPerBatch) spawnIndex = 0;
			oldestSpawn = _particleData[spawnIndex*16];
			
			invalidateBuffers(_vertexBufferDirty);
			invalidateBuffers(_particleDataDirty);
			invalidateBuffers(_vertexSpeedBufferDirty);
			
		}
	}
}
