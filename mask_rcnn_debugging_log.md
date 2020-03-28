# Mask RCNN Debugging Log 
#### Description: 
This file logs some bugs I fixed in matterport's maskrcnn python scripts when I try to retrain their mask rcnn model to specifically predict mammal shapes. Due to different package versions, some functions may be old(depracted) for me but not for you. Some fix that worked for me might not work for you also due to different environment configurations. Hope you find this log somewhat helpful. 
#### Date: 
03/27/2020
#### By: 
Di Hu 
#### Environment: 
- GPU: GeForece RTX 2080 
- CUDA: 10.1 
- TensorFlow: 2.1.0-rc2 
- Keras: 2.3.1 
- Mask RCNN: [GitHub repo with last update on Mar 9, 2019](https://github.com/matterport/Mask_RCNN/tree/master/mrcnn)

####Index
- [Fix in mrcnn/model.py](#fix-in-mrcnnmodelpy_1)
    - [Depracated functions in TensorFlow](#depracated-functions-in-tensorflow_1)
- [Fix in mrcnn/config.py](#fix-in-mrcnnconfigpy)
- [Fix in inspect_mammal_model.ipynb](#fix-in-inspect_mammal_modelipynb)
- [Fix in keras\callbacks.py](#fix-in-kerascallbackspy)
- [Fix in Jupyter notebook kernel file](#fix-in-jupyter-notebook-kernel-file)
- [Suggestion with VIA](#suggestion-with-via)


##Fix in mrcnn/model.py: 
####Error: TypeError("Using a `tf.Tensor` as a Python `bool` is not allowed.")
#####Fix: 
- Around line 2160+, comment out the `if` condition: 
    ```Python 
    for name in loss_names:
                layer = self.keras_model.get_layer(name)
                # if layer.output in self.keras_model.losses:
                #     continue
                loss = (
                    tf.reduce_mean(layer.output, keepdims=True)
                    * self.config.LOSS_WEIGHTS.get(name, 1.))
                self.keras_model.add_loss(loss)
    ```
#####Reference: [CSDN blog](https://blog.csdn.net/na_fantastic/article/details/102548647)

####Error: AttributeError: 'Model' object has no attribute 'metrics_tensors'
#####Fix: 
> change model.py file's line 2199 , which is "self.keras_model.metrics_tensors.append(loss)" to "self.keras_model.add_metric(loss, name)" and then with this command "python .\setup.py install" generate new egg file. You cannot directly change the content of the egg file
#####Reference: [GitHub issue forum](https://github.com/matterport/Mask_RCNN/issues/1754#issuecomment-570956587)

###Depracated functions in TensorFlow:  
####Error: module 'tensorflow' has no attribute 'random_shuffle'
#####Fix: 
- Change `tf.random_shuffle` to `tf.random.shuffle`
#####Reference: [stackoverflow forum](https://stackoverflow.com/a/59766874)

####Error: module 'tensorflow' has no attribute 'to_float'
#####Fix: 
> change tf.to_float call to tf.cast(..., dtype=tf.float32)
#####Reference: [GitHub issue forum](https://github.com/tensorflow/tensor2tensor/issues/1736#issuecomment-557933618)

####Error: module 'tensorflow' has no attribute 'log'
#####Fix: 
- change `tf.log` to `tf.math.log` 
#####Reference: [GitHub issue forum](https://github.com/matterport/Mask_RCNN/issues/1797#issuecomment-560553450)

####Error: module 'tensorflow' has no attribute 'set_intersection'
#####Fix: 
> tf.sets.set_intersection() -> tf.sets.intersection()
#####Reference: [GitHub issue forum](https://github.com/matterport/Mask_RCNN/issues/1797#issuecomment-578645639)

####Error: module 'tensorflow' has no attribute 'sparse_tensor_to_dense'
#####Fix: 
> tf.sparse_tensor_to_dense() -> tf.sparse.to_dense()
#####Reference: [GitHub issue forum](https://github.com/matterport/Mask_RCNN/issues/1797#issuecomment-578645639)

##Fix in mrcnn/config.py: 
####Error: 'InferenceConfig' object has no attribute 'PRE_NMS_LIMIT'
#####Fix: 
Update `config.py` file in `site-package\mrcnn` folder. Found out that the auto build files were an old version of mrcnn. 

##Fix in inspect_mammal_model.ipynb:    
####Error: len(images) must be equal to BATCH_SIZE
#####Fix: 
- Added more image item to the first list argument of `model.detect(list, verbose=1)` so that `len(list) == BATCH_SIZE)`. 
    - Ex: My BATCH_SIZE is 2, so I have `results = model.detect([image, image2], verbose=1)`
#####Reference: [GitHub issue forum](https://github.com/matterport/Mask_RCNN/issues/1285#issuecomment-498934815)

##Fix in keras\callbacks.py
####Error: AttributeError: 'Model' object has no attribute '_get_distribution_strategy'  
####Fix: 
- find keras\callbacks.py under "C:\Users\xxx\Miniconda3\Lib\site-packages\tensorflow_core\python\keras\callbacks.py"
- replace line 1529-1532 with code fix in this [link](https://github.com/tensorflow/tensorflow/pull/34870/files)
#####Reference: [GitHub issue forum](https://github.com/fizyr/keras-retinanet/issues/1239#issuecomment-571051288)

## Fix in Jupyter notebook kernel file:
####Error: Jupyter notebook cannot find conda installed packages
#####Fix: 
- in conda command window, enter `jupyter kernelspec list`
- copy the kernel path and open in file system 
- check and modify the python version in the kernel JSON file 
    - eg: in path "C:\Users\xxx\AppData\Roaming\jupyter\kernels\python3"
        ```JSON 
        {
         "argv": [
          "C:\\Users\\xxx\\Miniconda3\\python.exe",
          "-m",
          "ipykernel_launcher",
          "-f",
          "{connection_file}"
         ],
         "display_name": "Python 3",
         "language": "python"
        }
        ```

##Suggestion with VIA: 
####Error: JSON KeyError when loading [VIA](https://www.robots.ox.ac.uk/~vgg/software/via/via_demo.html) generated JSON file(image annotation data):   
```python
Traceback (most recent call last):
  File "mammal.py", line 365, in <module>
    train(model)
  File "mammal.py", line 189, in train
    dataset_val.load_mammal(args.dataset, "val")
  File "mammal.py", line 118, in load_mammal
    annotations = [a for a in annotations if a['regions']]
  File "mammal.py", line 118, in <listcomp>
    annotations = [a for a in annotations if a['regions']]
KeyError: 'regions'
```
#####Fix: 
It's probably due to an extra or a missing `{`  or a `}`. Use `Export Annotations (as json)` option under `Annotation` tab in VIA instead of `Save Project` would generate a cleaner JSON file and thus making datasets integration easier and less error-prone. 