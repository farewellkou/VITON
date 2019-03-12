## VITON: An Image-based Virtual Try-on Network
Code and dataset for the CVPR 2018 paper "VITON: An Image-based Virtual Try-on Network"

### Person representation extraction
The person representation used in this paper are extracted by a 2D pose estimator and a human parser:
* [Realtime Multi-Person Pose Estimation](https://github.com/ZheC/Realtime_Multi-Person_Pose_Estimation)
* [Self-supervised Structure-sensitive Learning](https://github.com/Engineering-Course/LIP_SSL)

### Dataset
The dataset is no longer publicly available due to copyright issues. For thoese who have already downloaded the dataset, please note that using or distributing it is illegal!

### Test (I tested in CPU mode.)

1. Download person representation extraction model and VITON pretrtained model.
    ```
    $ cd model
    $ ./get_model.sh
    ```
1. Set your human and product image at ```data/women_top``` and add a pair of images ```data/test_image_list.txt```.
    ```
    # Sample(human_image product image)
    000000_0.jpg 000000_1.jpg
    000001_0.jpg 000001_1.jpg
    000002_0.jpg 000002_1.jpg
    ```
1. Change the environment information in the code.
    ```
    1. prepare_data/make_pose.py line:10
       sys.path.append("/home/kouta/caffe_ssl/python")  # your pycaffe path
    2. prepare_data/make_segmatation.m line:10
       caffepath = '/home/kouta/caffe_ssl/matlab'; # your matlab path
    ```

1. Run pre-processing model.
    ```
    $ cd prepare_data
    $ matlab -nodesktop -nosplash -r 'make_segmatation; exit'
    $ python make_pose.py
    ```
    
1. Run first stage script.
    ```
    @ project root dir
    $ ./test_stage1.sh
    ```

1. Run shape context warp script.
    ```
    @ project root dir
    $ matlab -nodesktop -nosplash -r 'shape_context_warp; exit'
    ```

1. Run second stage script. You can get result at ```result/stage2```.
    ```
    @ project root dir
    $ ./test_stage2.sh
    ```

### Train

#### Prepare data
Go inside ```prepare_data```. 

First run ```extract_tps.m```. This will take sometime, you can try run it in parallel or directly download the pre-computed TPS control points via Google Drive and put them in ```data/tps/```.

Then run ```./preprocess_viton.sh```, and the generated TF records will be in ```prepare_data/tfrecord```.


#### First stage
Run ```train_stage1.sh```

#### Second stage
Run ```train_stage2.sh```


<!---
### Todo list
- [x] Code of testing the first stage.
- [x] Data preparation code.
- [x] Code of training the first stage.
- [x] Shape context matching and warping.
- [x] Code of testing the second stage.
- [x] Code of training the second stage.
-->

### Citation

If this code or dataset helps your research, please cite our paper:


    @inproceedings{han2017viton,
      title = {VITON: An Image-based Virtual Try-on Network},
      author = {Han, Xintong and Wu, Zuxuan and Wu, Zhe and Yu, Ruichi and Davis, Larry S},
      booktitle = {CVPR},
      year  = {2018},
    }
