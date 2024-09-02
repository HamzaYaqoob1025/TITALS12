import bpy
import sys
import os
import math
from mathutils import Matrix

def process_file(file_path):
    # Clear existing mesh objects
    bpy.ops.object.select_all(action='DESELECT')
    bpy.ops.object.select_by_type(type='MESH')
    bpy.ops.object.delete()

    # Import the file
    bpy.ops.import_scene.obj(filepath=file_path)

    # Get all imported objects
    imported_objects = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH']

    for obj in imported_objects:
        # Rotate around X axis by 90 degrees
        rotation_matrix = Matrix.Rotation(math.radians(90), 4, 'X')
        obj.matrix_world = rotation_matrix @ obj.matrix_world

        # Set origin to geometry center
        for _ in range(3):
            bpy.context.view_layer.objects.active = obj
            bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY')

        # Apply rotation
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)

    # Export the modified file
    output_path = file_path.replace('.obj', '_modified.obj')
    bpy.ops.export_scene.obj(filepath=output_path, use_selection=True, use_materials=True)

if __name__ == "__main__":
    if len(sys.argv) > 5:  # 5 is the index where custom args start in Blender
        process_file(sys.argv[5])
