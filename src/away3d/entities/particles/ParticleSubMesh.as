package away3d.entities.particles
{
	import away3d.materials.MaterialBase;
	import away3d.entities.Mesh;
	import away3d.core.base.SubGeometry;
	import away3d.core.managers.Stage3DProxy;
	import flash.display3D.VertexBuffer3D;
	import away3d.core.base.SubMesh;
	/**
	 * @author jalava
	 */
	public class ParticleSubMesh extends SubMesh 
	{
		public function ParticleSubMesh(subGeometry : SubGeometry, parentMesh : Mesh, material : MaterialBase = null)
		{
			super(subGeometry, parentMesh, material);
		}

		/**
		 * Retrieves the VertexBuffer3D object that contains vertex tangents.
		 * @param context The Context3D for which we request the buffer
		 * @return The VertexBuffer3D object that contains vertex tangents.
		 */
		public function getVertexCornerBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return (_subGeometry as ParticleSubGeometry).getVertexCornerBuffer(stage3DProxy);
		}

		public function getSpawnTimeBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return (_subGeometry as ParticleSubGeometry).getSpawnTimerBuffer(stage3DProxy);
		}

		public function getSpeedBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return (_subGeometry as ParticleSubGeometry).getParticleSpeedBuffer(stage3DProxy);
		}
		
	}
}
