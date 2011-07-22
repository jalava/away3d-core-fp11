package away3d.entities.particles
{
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.MaterialBase;
	import away3d.entities.Mesh;
	import away3d.core.base.SubGeometry;
	import away3d.core.base.SubMesh;
	/**
	 * @author jalava
	 */
	public class PointCloudSubMesh extends SubMesh
	{
		public function PointCloudSubMesh(subGeometry : SubGeometry, parentMesh : Mesh, material : MaterialBase = null)
		{
			super(subGeometry, parentMesh, material);
		}

		public function getVertexCornerBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return (_subGeometry as PointCloudSubGeometry).getVertexCornerBuffer(stage3DProxy);
		}

		public function getDirIndexBuffer(stage3DProxy : Stage3DProxy, dir : uint) : IndexBuffer3D
		{
			return (_subGeometry as PointCloudSubGeometry).getDirIndexBuffer(stage3DProxy, dir);
		}
		
		public function getParticleDataBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return (_subGeometry as PointCloudSubGeometry).getParticleDataBuffer(stage3DProxy);
		}
		
		
		
	}
}
