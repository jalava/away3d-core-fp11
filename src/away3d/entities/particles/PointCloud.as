package away3d.entities.particles
{
	import away3d.arcane;
	import away3d.events.GeometryEvent;
	import away3d.core.base.SubGeometry;
	import away3d.materials.PointCloudMaterial;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	import away3d.core.base.Geometry;

	use namespace arcane;

	/**
	 * @author jalava
	 */
	public class PointCloud extends Mesh
	{
		public function PointCloud(material:PointCloudMaterial, pointCloudData:Vector.<Number>, size:Number = 20, scale:Number = 0.1, chunks:uint = 1)
		{
			super(material);
			// TODO: Splitting!			
			if(chunks > 1) {
				addInSplits(size, scale, pointCloudData, chunks);
			}else { 
				_geometry.addSubGeometry(new PointCloudSubGeometry(size, size, scale,pointCloudData));
			}
		//	initGeometry();
		}
		private function addInSplits(size : Number, scale : Number, pointCloudData : Vector.<Number>, chunks:uint) : void {
			// Get even size split
			for(var cx:int = 0; cx<chunks;cx++) {
				var cxmin:int = size*cx/chunks;
				var cxmax:int = size*(cx+1)/chunks;
				for(var cy:int = 0;cy<chunks;cy++) {
					var cymin:int = size*cy/chunks;
					var cymax:int = size*(cy+1)/chunks;
					for(var cz:int = 0;cz<chunks;cz++) {
						var czmin:int = size*cz/chunks;
						var czmax:int = size*(cz+1)/chunks;
						trace("Creating chunk x:["+cxmin+".."+cxmax+"] y:["+cymin+".."+cymax+"] z:["+czmin+".."+czmax+"] ");
						var newSize:uint = size/chunks;
						var newPcData = new Vector.<Number>(newSize*newSize*newSize*4, true);
						for(var x:int = cxmin; x<cxmax; x++) {
							for(var y:int = cymin; y<cymax; y++) {
								for(var z:int = czmin; z<czmax; z++) {
									var pos:uint = x*size*size+y*size+z;
									var newPos:uint = (x-cxmin)*newSize*newSize+(y-cymin)*newSize+(z-czmin);
									newPcData[newPos*4] = pointCloudData[pos*4];
									newPcData[newPos*4+1] = pointCloudData[pos*4+1];
									newPcData[newPos*4+2] = pointCloudData[pos*4+2];
									newPcData[newPos*4+3] = pointCloudData[pos*4+3];									
								}
							}
						}
						var subGeom:SubGeometry = new PointCloudSubGeometry(size, newSize, scale, newPcData, cxmin, cymin, czmin);
						
						_geometry.addSubGeometry(subGeom);
					}
				}
			}
		}
		
		override protected function onSubGeometryAdded(event : GeometryEvent) : void
		{
			addPointCloudSubMesh(event.subGeometry);
		}
		
		public function addPointCloudSubMesh(subGeometry:SubGeometry):void {
			trace("Added submesh!");
			var subMesh : PointCloudSubMesh = new PointCloudSubMesh(subGeometry, this, null);
			var len : uint = _subMeshes.length;
			subMesh._index = len;
			_subMeshes[len] = subMesh;
		}
		
	}

}
