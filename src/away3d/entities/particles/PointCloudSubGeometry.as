package away3d.entities.particles
{
	import flash.display3D.IndexBuffer3D;
	import away3d.core.managers.Stage3DProxy;
	import flash.display3D.VertexBuffer3D;
	import away3d.core.base.SubGeometry;
	
	import away3d.arcane;
	
	use namespace arcane;
		
	/**
	 * @author jalava
	 */
	public class PointCloudSubGeometry extends SubGeometry
	{
		private var _dirindices:Vector.<Vector.<uint>>= new Vector.<Vector.<uint>>(48, true);
		private var _size:uint;
				
		public function PointCloudSubGeometry(totalSize:uint, size : uint, scale : Number, pointCloudData:Vector.<Number>, offsetx:int=0, offsety:int=0, offsetz:int = 0)
		{
			this._size = size;
			_vertexCornerIndices = new Vector.<Number>(size*size*size*4, true);
			var particleData:Vector.<Number> = new Vector.<Number>(size*size*size*16, true);
			var vertData:Vector.<Number> = new Vector.<Number>(size*size*size*12, true);
			var uvData:Vector.<Number> = new Vector.<Number>(size*size*size*8, true);
			for(var i=0;i<48;i++) {
				_dirindices[i] = new Vector.<uint>(size*size*size*6, true);
			}

			var x:uint = 0;
			var y:uint = 0;
			var z:uint = 0;
		
			var offset:int = -totalSize/2*scale;
			for(x=0;x<size;x++) {
				for(y=0;y<size;y++) {
					for(z=0;z<size;z++) {
						var idx:uint = x*size*size+y*size+z;
						var pos:uint = idx*12;
						// Vertex positioning
						vertData[pos] = vertData[pos+3] = vertData[pos+6] = vertData[pos+9] = offset+(x+offsetx)*scale;
						vertData[pos+1] = vertData[pos+4] = vertData[pos+7] = vertData[pos+10] = offset+(y+offsety)*scale;
						vertData[pos+2] = vertData[pos+5] = vertData[pos+8] = vertData[pos+11] = offset+(z+offsetz)*scale;
						pos = idx*8;						
						uvData[pos+0] = 0; uvData[pos+0+1] = 0;
						uvData[pos+2] = 1; uvData[pos+2+1] = 0;
						uvData[pos+4] = 1; uvData[pos+4+1] = 1;
						uvData[pos+6] = 0; uvData[pos+6+1] = 1;
						pos = idx*4;						
						_vertexCornerIndices[pos+0] = 0;
						_vertexCornerIndices[pos+1] = 1;
						_vertexCornerIndices[pos+2] = 2;
						_vertexCornerIndices[pos+3] = 3;
						pos = idx*16;
						particleData[pos] = particleData[pos+4] = particleData[pos+8] = particleData[pos+12] = pointCloudData[idx*4];
						particleData[pos+1] = particleData[pos+5] = particleData[pos+9] = particleData[pos+13] = pointCloudData[idx*4+1];
						particleData[pos+2] = particleData[pos+6] = particleData[pos+10] = particleData[pos+14] = pointCloudData[idx*4+2];
						particleData[pos+3] = particleData[pos+7] = particleData[pos+11] = particleData[pos+15] = pointCloudData[idx*4+3];
						
						addIndices(x,y,z, idx);								
					}
				}
			}
			_particleData = particleData;
			updateVertexData(vertData);
			updateUVData(uvData);
			_numIndices = _dirindices[0].length;
			_numTriangles = _numIndices/3;
			invalidateBuffers(_indexBufferDirty);
			_faceNormalsDirty = true;
		}
		
		private var lastDir:uint = 0;
		
		public function getDirIndexBuffer(stage3DProxy : Stage3DProxy, dir:uint) : IndexBuffer3D
		{
			var contextIndex : int = stage3DProxy._stage3DIndex;
			if (contextIndex > _maxIndex) _maxIndex = contextIndex;

			if (!_listeningForDispose[contextIndex]) initDisposeListener(stage3DProxy);

			if (_indexBufferDirty[contextIndex] || dir != lastDir || !_indexBuffer[contextIndex]) {
				(_indexBuffer[contextIndex] ||= stage3DProxy._context3D.createIndexBuffer(_numIndices)).uploadFromVector(_dirindices[dir], 0, _numIndices);
				_indexBufferDirty[contextIndex] = false;
				lastDir = dir;
			}

			return _indexBuffer[contextIndex];
		}		
		
		private var offsets:Vector.<uint> = new Vector.<uint>(6);		
		
		private function addIndices(x:uint, y:uint, z:uint, idx:uint):void {
			
			offsets[0] = x*_size*_size;
			offsets[1] = (_size-x-1)*_size*_size;
			offsets[2]= y*_size;
			offsets[3] = (_size-y-1)*_size;
			offsets[4] = z;
			offsets[5] = (_size-z-1);
			var xo:uint = 0;
			var yo:uint = 2;
			var zo:uint = 4;
						
			pushIndices2(0, xo, yo, zo, idx);
			pushIndices2(8, xo, zo, yo, idx);
			pushIndices2(16, yo, xo, zo, idx);
			pushIndices2(24, yo, zo, xo, idx);
			pushIndices2(32, zo, xo, yo, idx);
			pushIndices2(40, zo, yo, xo, idx);
		}
		
		private function pushIndices2(idxoffset:uint, a:uint,b:uint,c:uint, idx:uint):void {
			pushIndices(idxoffset++, offsets[a]  +offsets[b]  +offsets[c]  , idx);     // +a, +b, +c
			pushIndices(idxoffset++, offsets[a]  +offsets[b]  +offsets[c+1], idx);   // +a, +b, -c
			pushIndices(idxoffset++, offsets[a]  +offsets[b+1]+offsets[c]  , idx);   // +a, -b, +c
			pushIndices(idxoffset++, offsets[a]  +offsets[b+1]+offsets[c+1], idx); // +a, -b, -c
			pushIndices(idxoffset++, offsets[a+1]+offsets[b]  +offsets[c]  , idx); 	 // -a, +b, +c
			pushIndices(idxoffset++, offsets[a+1]+offsets[b]  +offsets[c+1], idx); // -a, +b, -c
			pushIndices(idxoffset++, offsets[a+1]+offsets[b+1]+offsets[c]  , idx); // -a, -b, +c
			pushIndices(idxoffset,   offsets[a+1]+offsets[b+1]+offsets[c+1], idx); // -a, -b, -c
		}
		
		private function pushIndices(dir:uint, idx:uint, partIdx:uint):void {
			
		//	trace("Push:"+partIdx+" to "+idx);
			_dirindices[dir][idx*6] = partIdx*4+3;
			_dirindices[dir][idx*6+1] = partIdx*4+1;
			_dirindices[dir][idx*6+2] = partIdx*4+0;
			_dirindices[dir][idx*6+3] = partIdx*4+3;
			_dirindices[dir][idx*6+4] = partIdx*4+2;
			_dirindices[dir][idx*6+5] = partIdx*4+1;
		}

		private var _vertexCornerIndices:Vector.<Number>;
		private var _vertexCornerBufferDirty:Vector.<Boolean> = new Vector.<Boolean>(8);
		private var _vertexCornerBuffers:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
	
		private var _particleData:Vector.<Number>;
		private var _particleDataDirty:Vector.<Boolean> = new Vector.<Boolean>(8);
		private var _particleDataBuffers:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
		
		public function getParticleDataBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D
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
			
	}
}
