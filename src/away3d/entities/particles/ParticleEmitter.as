package away3d.entities.particles
{
	import away3d.core.base.SubGeometry;
	import away3d.core.partition.EntityNode;
	import away3d.materials.ParticleMaterial;
	import flash.display.BitmapData;
	import away3d.entities.Mesh;
	import away3d.core.base.Geometry;
	import away3d.core.base.IMaterialOwner;
	import away3d.library.assets.IAsset;
	import flash.geom.Matrix3D;
	import away3d.animators.data.NullAnimation;
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.IndexBuffer3D;

	import away3d.materials.MaterialBase;
	import away3d.animators.data.AnimationBase;
	import away3d.animators.data.AnimationStateBase;
	import away3d.core.base.IRenderable;
	import away3d.entities.Entity;
	import away3d.arcane;
	
	use namespace arcane;

	/**
	 * @author jalava
	 */
	public class ParticleEmitter extends Mesh
	{
		private var _particleBatches:int;
		private var _particlesPerBatch:int;
		
		// Directions
		private var _phiMin:Number;
		private var _phiMax:Number;
		
		private var _thetaMin:Number;
		private var _thetaMax:Number;
		
		private var _speedMin:Number;
		private var _speedMax:Number;

		private var _rate:Number;				
				
		public function ParticleEmitter(particle:BitmapData, particleBatches:int = 4, particlesPerBatch:int = 4000)
		{
			// This handles the emitting of particles, managing of particle positions etc
			// See particleSubGeometry for handling particle geometries.
			//super();
			
			material = new ParticleMaterial(particle);
			_particleBatches = particleBatches;
			_particlesPerBatch = particlesPerBatch;
			_geometry =  new Geometry();
			for(var i:int = 0;i<_particleBatches;i++) {
				_geometry.addSubGeometry(new ParticleSubGeometry(_particlesPerBatch));							
			}
			initGeometry();			
		}
		
		public function addParticlesManual(x:Number, y:Number, z:Number):void
		{
			var subGeometry:ParticleSubGeometry = getOldestSubGeometry();
			subGeometry.spawnParticle(x,y,z);	
		}
		
		private function getOldestSubGeometry():ParticleSubGeometry
		{
			var sub:ParticleSubGeometry = _geometry.subGeometries[0] as ParticleSubGeometry ;
			for(var i:int = 1;i<_particleBatches;i++) {
				var t:ParticleSubGeometry = (_geometry.subGeometries[i] as ParticleSubGeometry);
				if(t.oldestSpawn < sub.oldestSpawn) {
					sub = t; 							
				}
			}			
			return sub;
		}

		override protected function initGeometry() : void
		{
			var subGeoms : Vector.<SubGeometry> = _geometry.subGeometries;

			for (var i : uint = 0; i < subGeoms.length; ++i)
				addParticleSubMesh(subGeoms[i] as ParticleSubGeometry);

			if (_geometry.animation) animationState = _geometry.animation.createAnimationState();
		}
		
		public function addParticleSubMesh(subGeometry:SubGeometry) {
			var subMesh : ParticleSubMesh = new ParticleSubMesh(subGeometry, this, null);
			var len : uint = _subMeshes.length;
			subMesh._index = len;
			_subMeshes[len] = subMesh;
		}

	}
}
