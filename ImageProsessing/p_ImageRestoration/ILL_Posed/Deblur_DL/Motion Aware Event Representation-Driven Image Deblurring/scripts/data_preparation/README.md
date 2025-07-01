### Used for generate Deviation Accumulation Event Representation from raw event (h5 file)

Convert raw GoPro event file (h5) to DA event representation file (h5):
```
python make_voxels_esim.py --input_path /your/path/to/raw/event/h5file --save_path /your/path/to/save/voxel/h5file --voxel_method ASYNAV_esim
```

Convert raw REBlur event file (h5) to DA event representation file (h5):
```
python make_voxels_real.py --input_path /your/path/to/raw/event/h5file --save_path /your/path/to/save/voxel/h5file --voxel_method ASYNAV_real_data
```

