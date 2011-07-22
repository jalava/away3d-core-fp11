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
		public function PointCloud(material:PointCloudMaterial, size:Number = 20, scale:Number = 0.1)
		{
			super(material);			
			_geometry.addSubGeometry(new PointCloudSubGeometry(size, scale));
		//	initGeometry();
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
