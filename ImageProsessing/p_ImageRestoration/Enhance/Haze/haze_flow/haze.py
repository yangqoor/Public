import cv2
import numpy as np
import os
import torch
import PIL.Image as pil
import matplotlib as mpl
import matplotlib.cm as cm
import networks
from torchvision import transforms
from layers import disp_to_depth
from PIL import Image
import shutil
import json
import argparse
from tqdm import tqdm
import time
import matplotlib.pyplot as plt
import warnings
from torchvision.models import _utils
from PIL import Image

warnings.filterwarnings("ignore", category=UserWarning, module=_utils.__name__)
warnings.filterwarnings("ignore", category=DeprecationWarning, module=Image.__name__)


def create_depth_map(file_path):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model_path = "./models/mono+stereo_1024x320"
    # print("-> Loading model from ", model_path)
    encoder_path = os.path.join(model_path, "encoder.pth")
    depth_decoder_path = os.path.join(model_path, "depth.pth")

    # LOADING PRETRAINED MODEL
    # print("   Loading pretrained encoder")
    encoder = networks.ResnetEncoder(18, False)
    loaded_dict_enc = torch.load(encoder_path, map_location=device)

    # extract the height and width of image that this model was trained with
    feed_height = loaded_dict_enc['height']
    feed_width = loaded_dict_enc['width']
    filtered_dict_enc = {k: v for k, v in loaded_dict_enc.items() if k in encoder.state_dict()}
    encoder.load_state_dict(filtered_dict_enc)
    encoder.to(device)
    encoder.eval()

    # print("   Loading pretrained decoder")
    depth_decoder = networks.DepthDecoder(
        num_ch_enc=encoder.num_ch_enc, scales=range(4))

    loaded_dict = torch.load(depth_decoder_path, map_location=device)
    depth_decoder.load_state_dict(loaded_dict)

    depth_decoder.to(device)
    depth_decoder.eval()
    with torch.no_grad():

        input_image = pil.open(file_path).convert('RGB')
        original_width, original_height = input_image.size
        input_image = input_image.resize((feed_width, feed_height), Image.Resampling.LANCZOS)
        input_image = transforms.ToTensor()(input_image).unsqueeze(0)

        # Prediction
        input_image = input_image.to(device)
        features = encoder(input_image)
        outputs = depth_decoder(features)

        disp = outputs[("disp", 0)]
        disp_resized = torch.nn.functional.interpolate(
            disp, (original_height, original_width), mode="bilinear", align_corners=False)

        # Convert the depth map to a numpy array
        depth_map = disp_resized.squeeze().cpu().numpy()

        return depth_map


def add_haze_to_image(image_file, depth_map, beta=1 , atmosphere_light=1 ,  gaussian_filter_size=15 , gaussian_std_dev=0, display=False):

    # image = Image.open(image_file)
    image = Image.open(image_file).convert('RGB')
    depth_map_normalized = (depth_map - depth_map.min()) / (depth_map.max() - depth_map.min())


    # print('beta', args.beta)
    # print('atmosphere_light', args.atmosphere_light)
    # print('gaussian_filter_size', args.gaussian_filter_size)
    # print('gaussian_std_dev', args.gaussian_std_dev)
    
    transmission_map = 1 - np.exp(-args.beta * depth_map_normalized)

    # Apply Gaussian blur to the transmission map

    transmission_map_blurred = cv2.GaussianBlur(transmission_map, (args.gaussian_filter_size, args.gaussian_filter_size), args.gaussian_std_dev)

    # # apply bilaterial blur to images

    # transmission_map_blurred = cv2.bilateralFilter(transmission_map.astype(np.float32), 15, 75, 75)

    transmission_map_3c = np.repeat(transmission_map_blurred[:, :, np.newaxis], 3, axis=2)

    # transmission_map_3c = np.repeat(transmission_map[:, :, np.newaxis], 3, axis=2)

    # hazy_image = image * transmission_map_3c + args.atmosphere_light * (1 - transmission_map_3c)
    hazy_image = image * transmission_map_3c + np.full_like(image, args.atmosphere_light) * (1 - transmission_map_3c)

    # print("hazy_image")
    # print(hazy_image)
    hazy_image = Image.fromarray(np.uint8(hazy_image))

    if display:
        image.show(title='Original Image')
        hazy_image.show(title='Hazy Image')

    return hazy_image



def display_kitti15_samples(directory, num_samples=2):
    samples_processed = 0
    for root, _, files in os.walk(directory):
        if not os.path.basename(root) in ['image_2', 'image_3']:
            continue

        for file in files:
            if samples_processed >= num_samples:
                break

            file_path = os.path.join(root, file)

            if file_path.endswith('.png'):
                print(f"Displaying sample {samples_processed + 1}: {file_path}")
                depth_map = create_depth_map(file_path)
                hazy_image = add_haze_to_image(file_path, depth_map, display=False)  # Set display to False to avoid showing the image twice

                # Display the original, hazy image and depth map
                original_image = cv2.imread(file_path)
                original_image = cv2.cvtColor(original_image, cv2.COLOR_BGR2RGB)
                depth_colormap = cm.jet(depth_map)
                
                fig, ax = plt.subplots(1, 3, figsize=(15, 5))
                ax[0].imshow(original_image)
                ax[0].set_title('Original Image')
                ax[0].axis('off')
                
                ax[1].imshow(np.asarray(hazy_image))
                ax[1].set_title('Hazy Image')
                ax[1].axis('off')

                ax[2].imshow(depth_colormap)
                ax[2].set_title('Depth Map')
                ax[2].axis('off')
                
                plt.show()

                samples_processed += 1

        if samples_processed >= num_samples:
            break

    print(f"Displayed kitti15 {samples_processed} samples")

def display_sintel_samples(input_dir, num_samples=2):
    samples_processed = 0
    for dirpath, _, filenames in os.walk(input_dir):
        for filename in filenames:
            if samples_processed >= num_samples:
                break

            if not filename.endswith(".png"):
                continue

            if "flow" in dirpath or "invalid" in dirpath:
                continue

            file_path = os.path.join(dirpath, filename)

            print(f"Displaying sample {samples_processed + 1}: {file_path}")
            depth_map = create_depth_map(file_path)
            hazy_image = add_haze_to_image(file_path, depth_map, display=False)  # Set display to False to avoid showing the image twice

            # Display the original, hazy image and depth map
            original_image = cv2.imread(file_path)
            original_image = cv2.cvtColor(original_image, cv2.COLOR_BGR2RGB)
            depth_colormap = cm.jet(depth_map)
            
            fig, ax = plt.subplots(1, 3, figsize=(15, 5))
            ax[0].imshow(original_image)
            ax[0].set_title('Original Image')
            ax[0].axis('off')
            
            ax[1].imshow(np.asarray(hazy_image))
            ax[1].set_title('Hazy Image')
            ax[1].axis('off')

            ax[2].imshow(depth_colormap)
            ax[2].set_title('Depth Map')
            ax[2].axis('off')
            
            plt.show()

            samples_processed += 1

        if samples_processed >= num_samples:
            break

    print(f"Displayed sintel {samples_processed} samples")


def display_flyingchairs_samples(input_dir, num_samples=2):
    samples_processed = 0
    for dirpath, _, filenames in os.walk(input_dir):
        for filename in filenames:
            if samples_processed >= num_samples:
                break

            if not filename.endswith(".ppm"):
                continue

            if "flow" in filename:
                continue

            file_path = os.path.join(dirpath, filename)

            print(f"Displaying sample {samples_processed + 1}: {file_path}")
            depth_map = create_depth_map(file_path)
            hazy_image = add_haze_to_image(file_path, depth_map, display=False)  # Set display to False to avoid showing the image twice

            # Display the original, hazy image and depth map
            original_image = cv2.imread(file_path)
            original_image = cv2.cvtColor(original_image, cv2.COLOR_BGR2RGB)
            depth_colormap = cm.jet(depth_map)
            
            fig, ax = plt.subplots(1, 3, figsize=(15, 5))
            ax[0].imshow(original_image)
            ax[0].set_title('Original Image')
            ax[0].axis('off')
            
            ax[1].imshow(np.asarray(hazy_image))
            ax[1].set_title('Hazy Image')
            ax[1].axis('off')

            ax[2].imshow(depth_colormap)
            ax[2].set_title('Depth Map')
            ax[2].axis('off')
            
            plt.show()

            samples_processed += 1

        if samples_processed >= num_samples:
            break

    print(f"Displayed flyingchairs {samples_processed} samples")

def display_flyingthings3d_samples(directory, num_samples=2):
    samples_processed = 0
    for dirpath, _, filenames in os.walk(directory):
        for filename in filenames:
            if samples_processed >= num_samples:
                break

            if not filename.endswith(".png"):
                continue

            if not os.path.basename(dirpath) in ['left', 'right']:
                continue

            file_path = os.path.join(dirpath, filename)

            print(f"Displaying sample {samples_processed + 1}: {file_path}")
            depth_map = create_depth_map(file_path)
            hazy_image = add_haze_to_image(file_path, depth_map, display=False)  # Set display to False to avoid showing the image twice

            # Display the original, hazy image and depth map
            original_image = cv2.imread(file_path)
            original_image = cv2.cvtColor(original_image, cv2.COLOR_BGR2RGB)
            depth_colormap = cm.jet(depth_map)
            
            fig, ax = plt.subplots(1, 3, figsize=(15, 5))
            ax[0].imshow(original_image)
            ax[0].set_title('Original Image')
            ax[0].axis('off')
            
            ax[1].imshow(np.asarray(hazy_image))
            ax[1].set_title('Hazy Image')
            ax[1].axis('off')

            ax[2].imshow(depth_colormap)
            ax[2].set_title('Depth Map')
            ax[2].axis('off')
            
            plt.show()

            samples_processed += 1
        if samples_processed >= num_samples:
            break

    print(f"Displayed flyingthings3d {samples_processed} samples")

def display_hd1k_samples(directory, num_samples=2):
    samples_processed = 0
    for dirpath, _, filenames in os.walk(directory):
        for filename in filenames:
            if samples_processed >= num_samples:
                break

            if not filename.endswith(".png"):
                continue

            if 'hd1k_flow_gt' in dirpath or 'hd1k_flow_uncertainty' in dirpath:
                continue

            file_path = os.path.join(dirpath, filename)

            print(f"Displaying sample {samples_processed + 1}: {file_path}")
            depth_map = create_depth_map(file_path)
            hazy_image = add_haze_to_image(file_path, depth_map, display=False)  # Set display to False to avoid showing the image twice

            # Display the original, hazy image and depth map
            original_image = cv2.imread(file_path)
            original_image = cv2.cvtColor(original_image, cv2.COLOR_BGR2RGB)
            depth_colormap = cm.jet(depth_map)
            
            fig, ax = plt.subplots(1, 3, figsize=(15, 5))
            ax[0].imshow(original_image)
            ax[0].set_title('Original Image')
            ax[0].axis('off')
            
            ax[1].imshow(np.asarray(hazy_image))
            ax[1].set_title('Hazy Image')
            ax[1].axis('off')

            ax[2].imshow(depth_colormap)
            ax[2].set_title('Depth Map')
            ax[2].axis('off')
            
            plt.show()

            samples_processed += 1

        if samples_processed >= num_samples:
            break

    print(f"Displayed HD1K {samples_processed} samples")

def display_chairssdhom_samples(directory, num_samples=2):
    samples_processed = 0

    target_directories = [os.path.join(directory, "data", d, sd) for d in ["train", "test"] for sd in ["t0", "t1"]]

    for target_dir in target_directories:
        for dirpath, _, filenames in os.walk(target_dir):
            for filename in filenames:
                if samples_processed >= num_samples:
                    break

                if not filename.endswith(".png"):
                    continue

                file_path = os.path.join(dirpath, filename)

                print(f"Displaying sample {samples_processed + 1}: {file_path}")
                depth_map = create_depth_map(file_path)
                hazy_image = add_haze_to_image(file_path, depth_map, display=False)  # Set display to False to avoid showing the image twice

                # Display the original, hazy image and depth map
                original_image = cv2.imread(file_path)
                original_image = cv2.cvtColor(original_image, cv2.COLOR_BGR2RGB)
                depth_colormap = cm.jet(depth_map)
                
                fig, ax = plt.subplots(1, 3, figsize=(15, 5))
                ax[0].imshow(original_image)
                ax[0].set_title('Original Image')
                ax[0].axis('off')
                
                ax[1].imshow(np.asarray(hazy_image))
                ax[1].set_title('Hazy Image')
                ax[1].axis('off')

                ax[2].imshow(depth_colormap)
                ax[2].set_title('Depth Map')
                ax[2].axis('off')
                
                plt.show()

                samples_processed += 1

            if samples_processed >= num_samples:
                break

    print(f"Displayed ChairsSDHom {samples_processed} samples")

def display_flyingchairssocc_samples(directory, num_samples=2):
    samples_processed = 0
    image_files = []

    for dirpath, _, filenames in os.walk(directory):
        for filename in filenames:
            if not (filename.endswith("_img1.png") or filename.endswith("_img2.png")):
                continue

            file_path = os.path.join(dirpath, filename)
            print(f"Displaying sample {samples_processed + 1}: {file_path}")
            depth_map = create_depth_map(file_path)
            hazy_image = add_haze_to_image(file_path, depth_map, display=False)  # Set display to False to avoid showing the image twice
            # Display the original image
            original_image = cv2.imread(file_path)
            original_image = cv2.cvtColor(original_image, cv2.COLOR_BGR2RGB)
            depth_colormap = cm.jet(depth_map)
            
            fig, ax = plt.subplots(1, 3, figsize=(15, 5))
            ax[0].imshow(original_image)
            ax[0].set_title('Original Image')
            ax[0].axis('off')
            
            ax[1].imshow(np.asarray(hazy_image))
            ax[1].set_title('Hazy Image')
            ax[1].axis('off')

            ax[2].imshow(depth_colormap)
            ax[2].set_title('Depth Map')
            ax[2].axis('off')
            
            plt.show()
            samples_processed += 1
            if samples_processed >= num_samples:
                break
        if samples_processed >= num_samples:
            break

    print(f"Displayed FlyingChairsOcc {samples_processed} samples")

def display_flyingthings3d_subset_samples(directory, num_samples=2):
    samples_processed = 0  
    image_files = [os.path.join(dirpath, filename) for dirpath, _, filenames in os.walk(directory) for filename in filenames if filename.endswith(".png")]

    for file_path in image_files:
        if samples_processed >= num_samples:
            break

        print(f"Displaying sample {samples_processed + 1}: {file_path}")
        depth_map = create_depth_map(file_path)
        hazy_image = add_haze_to_image(file_path, depth_map, display=False)  # Set display to False to avoid showing the image twice

        # Display the original and hazy image
        original_image = cv2.imread(file_path)
        original_image = cv2.cvtColor(original_image, cv2.COLOR_BGR2RGB)

        fig, ax = plt.subplots(1, 2, figsize=(10, 5))
        ax[0].imshow(original_image)
        ax[0].set_title('Original Image')
        ax[0].axis('off')

        ax[1].imshow(np.asarray(hazy_image))
        ax[1].set_title('Hazy Image')
        ax[1].axis('off')

        plt.show()

        samples_processed += 1

    print(f"Displayed FlyingThings3D_subset {samples_processed} samples")


def clone_directory(src, dst):
	shutil.copytree(src, dst)

def add_haze_to_kitti_images_in_directory(directory, checkpoint_file, beta=0.6, atmosphere_light=200, gaussian_filter_size=15, gaussian_std_dev=0):
    num_images = 0
    checkpoints = {}

    if os.path.exists(checkpoint_file):
        with open(checkpoint_file, 'r') as f:
            checkpoints = json.load(f)

    image_files = []
    for root, _, files in os.walk(directory):
        if not os.path.basename(root) in ['image_2', 'image_3']:
            continue
        for file in files:
            if file.endswith('.png'):
                image_files.append(os.path.join(root, file))

    print(f"Total number of samples: {len(image_files)}")

    start_time = time.time()
    for file_path in tqdm(image_files, desc="Adding haze"):
        rel_file_path = os.path.relpath(file_path, directory)

        if rel_file_path in checkpoints and checkpoints[rel_file_path] == True:
            print(f"Skipping already processed image: {file_path}")
        else:
            depth_map = create_depth_map(file_path)
            hazy_image = add_haze_to_image(file_path, depth_map, beta, atmosphere_light, gaussian_filter_size, gaussian_std_dev)
            hazy_image.save(file_path)
            num_images += 1
            checkpoints[rel_file_path] = True
            with open(checkpoint_file, 'w') as f:
                json.dump(checkpoints, f)

    end_time = time.time()
    print(f"Time taken to add haze: {end_time - start_time:.2f} seconds")

    return num_images

##############################
#adding haze to sintel dataset

def add_haze_to_sintel_images_in_directory(directory, checkpoint_file, gaussian_filter_size, gaussian_std_dev, beta=0.6, atmosphere_light=200, display=False):

    num_samples = 0
    checkpoints = {}

    if os.path.exists(checkpoint_file):
        with open(checkpoint_file, 'r') as f:
            checkpoints = json.load(f)

    image_files = []
    for dirpath, _, filenames in os.walk(directory):
        for filename in filenames:
            if filename.endswith(".png") and "flow" not in dirpath and "invalid" not in dirpath:
                image_files.append(os.path.join(dirpath, filename))

    print(f"Total number of samples: {len(image_files)}")

    start_time = time.time()
    for file_path in tqdm(image_files, desc="Adding haze"):
        rel_file_path = os.path.relpath(file_path, directory)
        # outpath = os.path.join(output_dir, rel_file_path)

        if rel_file_path in checkpoints and checkpoints[rel_file_path] == True:
            print(f"Skipping already processed image: {file_path}")
        else:
            depth_map = create_depth_map(file_path)
            hazy_image = add_haze_to_image(file_path, depth_map, beta, atmosphere_light, gaussian_filter_size, gaussian_std_dev)
            # os.makedirs(os.path.dirname(outpath), exist_ok=True)
            hazy_image.save(file_path)
            num_samples += 1
            checkpoints[rel_file_path] = True
            with open(checkpoint_file, 'w') as f:
                json.dump(checkpoints, f)

    end_time = time.time()
    print(f"Time taken to add haze: {end_time - start_time:.2f} seconds")

    return num_samples


#################
### adding haze to flyingchairs dataset

def add_haze_to_flyingchairs_images_in_directory(directory, checkpoint_file, gaussian_filter_size, gaussian_std_dev, beta=0.6, atmosphere_light=200, display=False):

    num_samples = 0
    checkpoints = {}

    if os.path.exists(checkpoint_file):
        with open(checkpoint_file, 'r') as f:
            checkpoints = json.load(f)

    image_files = []
    for dirpath, _, filenames in os.walk(directory):
        for filename in filenames:
            if filename.endswith(".ppm"):
                image_files.append(os.path.join(dirpath, filename))

    print(f"Total number of samples: {len(image_files)}")

    start_time = time.time()
    for file_path in tqdm(image_files, desc="Adding haze"):
        rel_file_path = os.path.relpath(file_path, directory)

        if rel_file_path in checkpoints and checkpoints[rel_file_path] == True:
            print(f"Skipping already processed image: {file_path}")
        else:
            depth_map = create_depth_map(file_path)
            hazy_image = add_haze_to_image(file_path, depth_map, beta, atmosphere_light, gaussian_filter_size, gaussian_std_dev)
            hazy_image.save(file_path)
            num_samples += 1
            checkpoints[rel_file_path] = True
            with open(checkpoint_file, 'w') as f:
                json.dump(checkpoints, f)

    end_time = time.time()
    print(f"Time taken to add haze: {end_time - start_time:.2f} seconds")

    return num_samples

def add_haze_to_flyingthings3d_images_in_directory(directory, checkpoint_file, gaussian_filter_size, gaussian_std_dev, beta=0.6, atmosphere_light=200, display=False):
    num_samples = 0
    checkpoints = {}

    if os.path.exists(checkpoint_file):
        with open(checkpoint_file, 'r') as f:
            checkpoints = json.load(f)

    image_files = []
    for dirpath, _, filenames in os.walk(directory):
        for filename in filenames:
            if filename.endswith(".png") and (os.path.basename(dirpath) in ['left', 'right']):
                image_files.append(os.path.join(dirpath, filename))

    print(f"Total number of samples: {len(image_files)}")

    start_time = time.time()
    for file_path in tqdm(image_files, desc="Adding haze"):
        rel_file_path = os.path.relpath(file_path, directory)

        if rel_file_path in checkpoints and checkpoints[rel_file_path] == True:
            print(f"Skipping already processed image: {file_path}")
        else:
            depth_map = create_depth_map(file_path)
            hazy_image = add_haze_to_image(file_path, depth_map, beta, atmosphere_light, gaussian_filter_size, gaussian_std_dev)
            hazy_image.save(file_path)
            num_samples += 1
            checkpoints[rel_file_path] = True
            with open(checkpoint_file, 'w') as f:
                json.dump(checkpoints, f)

    end_time = time.time()
    print(f"Time taken to add haze: {end_time - start_time:.2f} seconds")

    return num_samples

def add_haze_to_hd1k_images_in_directory(directory, checkpoint_file, gaussian_filter_size, gaussian_std_dev, beta=0.6, atmosphere_light=200, display=False):
    num_samples = 0
    checkpoints = {}

    if os.path.exists(checkpoint_file):
        with open(checkpoint_file, 'r') as f:
            checkpoints = json.load(f)

    image_files = []
    for dirpath, _, filenames in os.walk(directory):
        for filename in filenames:
            if filename.endswith(".png") and 'hd1k_flow_gt' not in dirpath and 'hd1k_flow_uncertainty' not in dirpath:
                image_files.append(os.path.join(dirpath, filename))

    print(f"Total number of samples: {len(image_files)}")

    start_time = time.time()
    for file_path in tqdm(image_files, desc="Adding haze"):
        rel_file_path = os.path.relpath(file_path, directory)

        if rel_file_path in checkpoints and checkpoints[rel_file_path] == True:
            print(f"Skipping already processed image: {file_path}")
        else:
            depth_map = create_depth_map(file_path)
            hazy_image = add_haze_to_image(file_path, depth_map, beta, atmosphere_light, gaussian_filter_size, gaussian_std_dev)
            hazy_image.save(file_path)
            num_samples += 1
            checkpoints[rel_file_path] = True
            with open(checkpoint_file, 'w') as f:
                json.dump(checkpoints, f)

    end_time = time.time()
    print(f"Time taken to add haze: {end_time - start_time:.2f} seconds")

    return num_samples


def add_haze_to_chairssdhom_images_in_directory(directory, checkpoint_file, gaussian_filter_size, gaussian_std_dev, beta=0.6, atmosphere_light=200, display=False):
    num_samples = 0
    checkpoints = {}

    if os.path.exists(checkpoint_file):
        with open(checkpoint_file, 'r') as f:
            checkpoints = json.load(f)
            
    target_directories = [os.path.join(directory, "data", d, sd) for d in ["train", "test"] for sd in ["t0", "t1"]]
    image_files = []

    for target_dir in target_directories:
        image_files.extend([os.path.join(dirpath, filename) for dirpath, _, filenames in os.walk(target_dir) for filename in filenames if filename.endswith(".png")])

    print(f"Total number of samples: {len(image_files)}")

    start_time = time.time()
    for file_path in tqdm(image_files, desc="Adding haze"):
        rel_file_path = os.path.relpath(file_path, directory)

        if rel_file_path in checkpoints and checkpoints[rel_file_path] == True:
            print(f"Skipping already processed image: {file_path}")
        else:
            depth_map = create_depth_map(file_path)
            hazy_image = add_haze_to_image(file_path, depth_map, beta, atmosphere_light, gaussian_filter_size, gaussian_std_dev)
            hazy_image.save(file_path)
            num_samples += 1
            checkpoints[rel_file_path] = True
            with open(checkpoint_file, 'w') as f:
                json.dump(checkpoints, f)

    end_time = time.time()
    print(f"Time taken to add haze: {end_time - start_time:.2f} seconds")

    return num_samples

def add_haze_to_flyingchairsocc(directory, checkpoint_file, gaussian_filter_size, gaussian_std_dev, beta=0.6, atmosphere_light=200):
    num_samples = 0
    checkpoints = {}

    if os.path.exists(checkpoint_file):
        with open(checkpoint_file, 'r') as f:
            checkpoints = json.load(f)

    image_files = [os.path.join(dirpath, filename) for dirpath, _, filenames in os.walk(directory) for filename in filenames if filename.endswith(("_img1.png", "_img2.png"))]

    print(f"Total number of samples: {len(image_files)}")
    start_time = time.time()

    for file_path in tqdm(image_files, desc="Adding haze"):
        rel_file_path = os.path.relpath(file_path, directory)

        if rel_file_path in checkpoints and checkpoints[rel_file_path] == True:
            print(f"Skipping already processed image: {file_path}")
        else:
            depth_map = create_depth_map(file_path)
            hazy_image = add_haze_to_image(file_path, depth_map, beta, atmosphere_light, gaussian_filter_size, gaussian_std_dev)
            hazy_image.save(file_path)
            num_samples += 1
            checkpoints[rel_file_path] = True

        with open(checkpoint_file, 'w') as f:
            json.dump(checkpoints, f)

    end_time = time.time()
    print(f"Added haze to {num_samples} FlyingChairsOcc samples in {end_time - start_time:.2f} seconds")

    return num_samples


def add_haze_to_flyingthings3d_subset(directory, checkpoint_file, gaussian_filter_size, gaussian_std_dev, beta=0.6, atmosphere_light=200):
    num_samples = 0
    checkpoints = {}

    if os.path.exists(checkpoint_file):
        with open(checkpoint_file, 'r') as f:
            checkpoints = json.load(f)
    image_files = [os.path.join(dirpath, filename) for dirpath, _, filenames in os.walk(directory) for filename in filenames if filename.endswith(".png")]

    print(f"Total number of samples: {len(image_files)}")
    start_time = time.time()

    for file_path in tqdm(image_files, desc="Adding haze"):
        rel_file_path = os.path.relpath(file_path, directory)

        if rel_file_path in checkpoints and checkpoints[rel_file_path] == True:
            print(f"Skipping already processed image: {file_path}")
        else:
            depth_map = create_depth_map(file_path)
            hazy_image = add_haze_to_image(file_path, depth_map, beta, atmosphere_light, gaussian_filter_size, gaussian_std_dev)
            hazy_image.save(file_path)
            num_samples += 1
            checkpoints[rel_file_path] = True

        with open(checkpoint_file, 'w') as f:
            json.dump(checkpoints, f)

    end_time = time.time()
    print(f"Added haze to {num_samples} FlyingThings3D_subset samples in {end_time - start_time:.2f} seconds")

    return num_samples

def is_directory_structure_identical(src, dst):
    for src_root, src_dirs, src_files in os.walk(src):
        dst_root = src_root.replace(src, dst)

        if not os.path.exists(dst_root):
            return False

        dst_dirs, dst_files = [], []
        for _, dirs, files in os.walk(dst_root):
            dst_dirs = dirs
            dst_files = files
            break

        if set(src_dirs) != set(dst_dirs) or set(src_files) != set(dst_files):
            return False

    return True


displayed_samples = False


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Add haze to images using depth maps.')
    parser.add_argument('--beta', type=float, default=1, help='Haze scattering coefficient value')
    parser.add_argument('--atmosphere_light', type=float, default=185, help='Atmospheric light value')
    parser.add_argument('--num_samples', type=int, default=1, help='Number of samples to display (default: 1)')

    parser.add_argument('--src_dir', type=str, required=True, help='Source directory of the dataset')
    parser.add_argument('--dst_dir', type=str, required=True, help='Destination directory for the hazy dataset')
    parser.add_argument('--dataset', type=str, required=True, choices=['sintel', 'kitti15', 'flyingchairs', 'flyingthings3d', 'hd1k', 'chairssdhom', 'flyingchairsocc'], help='Dataset to be used (sintel or kitti)')
    parser.add_argument('--gaussian_filter_size', type=int, default=5, help='Gaussian filter size for blurring the transmission map (default: 15)')
    parser.add_argument('--gaussian_std_dev', type=float, default=3, help='Gaussian standard deviation for blurring the transmission map (default: 0)')

    args = parser.parse_args()
    src_dir = args.src_dir
    dst_dir = args.dst_dir
    dataset = args.dataset
    beta = args.beta
    atmosphere_light = args.atmosphere_light
    gaussian_filter_size = args.gaussian_filter_size
    gaussian_std_dev = args.gaussian_std_dev


    checkpoint_file = f'{dataset}_checkpoints.json'

    if dataset == 'kitti15':
        # Add KITTI-specific code here
        if not displayed_samples:
            print(f"Displaying samples from {src_dir}...")
            display_kitti15_samples(src_dir, args.num_samples)
            displayed_samples = True

    elif dataset == 'sintel':
        # Add Sintel-specific code here
        if not displayed_samples:
            print(f"Displaying samples from {src_dir}...")
            display_sintel_samples(src_dir, args.num_samples)
            displayed_samples = True
    elif dataset == 'flyingchairs':
        # Add FlyingChairs-specific code here
        if not displayed_samples:
            print(f"Displaying samples from {src_dir}...")
            display_flyingchairs_samples(src_dir, args.num_samples)
            displayed_samples = True

    elif dataset == 'flyingthings3d':
        if not displayed_samples:
            print(f"Displaying samples from {src_dir}...")
            display_flyingthings3d_samples(src_dir, args.num_samples)
            displayed_samples = True

    elif dataset == 'hd1k':
        if not displayed_samples:
            print(f"Displaying samples from {src_dir}...")
            display_hd1k_samples(src_dir, args.num_samples)
            displayed_samples = True

    elif dataset == 'chairssdhom':
        if not displayed_samples:
            print(f"Displaying samples from {src_dir}...")
            display_chairssdhom_samples(src_dir, args.num_samples)
            displayed_samples = True

    elif dataset == 'flyingchairsocc':
        if not displayed_samples:
            print(f"Displaying samples from {src_dir}...")
            display_flyingchairssocc_samples(src_dir, args.num_samples)
            displayed_samples = True

    elif dataset == 'flyingthings3d_subset':
        if not displayed_samples:
            print(f"Displaying samples from {src_dir}...")
            display_flyingthings3d_subset_samples(src_dir, args.num_samples)
            displayed_samples = True

    proceed = input("Do you want to proceed with cloning and hazing the dataset? (y/n): ")

    if proceed.lower() != 'y':
        print("Aborted.")
        exit()

    if os.path.exists(dst_dir):
        if is_directory_structure_identical(src_dir, dst_dir):
            print(f"Directory structure already exists in {dst_dir}. Skipping cloning.")
        else:
            shutil.rmtree(dst_dir)
            print(f"Removed existing directory: {dst_dir}")
            print(f"Cloning directory {src_dir} to {dst_dir}...")
            clone_directory(src_dir, dst_dir)
            print(f"Clone completed.")
    else:
        print(f"Cloning directory {src_dir} to {dst_dir}...")
        clone_directory(src_dir, dst_dir)
        print(f"Clone completed.")

    print(f"Starting to add haze to images in {dst_dir}...")
    if dataset == 'kitti15':
        num_samples = add_haze_to_kitti_images_in_directory(dst_dir, checkpoint_file, args.beta, args.atmosphere_light, args.gaussian_filter_size, args.gaussian_std_dev)
    elif dataset == 'sintel':
        num_samples = add_haze_to_sintel_images_in_directory(dst_dir, checkpoint_file,  args.gaussian_filter_size, args.gaussian_std_dev, args.beta, args.atmosphere_light)
    # print(f"Adding haze completed: {num_samples} samples processed")

    elif dataset == 'flyingchairs':
        num_samples = add_haze_to_flyingchairs_images_in_directory(dst_dir, checkpoint_file, args.gaussian_filter_size, args.gaussian_std_dev, args.beta, args.atmosphere_light)
    
    elif dataset == 'flyingthings3d':
        num_samples = add_haze_to_flyingthings3d_images_in_directory(dst_dir, checkpoint_file, args.gaussian_filter_size, args.gaussian_std_dev, args.beta, args.atmosphere_light)
    
    elif dataset == 'hd1k':
        num_samples = add_haze_to_hd1k_images_in_directory(dst_dir, checkpoint_file, args.gaussian_filter_size, args.gaussian_std_dev, args.beta, args.atmosphere_light)

    elif dataset == 'chairssdhom':
        num_samples = add_haze_to_chairssdhom_images_in_directory(dst_dir, checkpoint_file, args.gaussian_filter_size, args.gaussian_std_dev, args.beta, args.atmosphere_light)

    elif dataset == 'flyingchairsocc':
        num_samples = add_haze_to_flyingchairsocc(dst_dir, checkpoint_file, args.gaussian_filter_size, args.gaussian_std_dev, args.beta, args.atmosphere_light)
    
    elif dataset == 'flyingthings3d_subset':
        num_samples = add_haze_to_flyingthings3d_subset(dst_dir, checkpoint_file, args.gaussian_filter_size, args.gaussian_std_dev, args.beta, args.atmosphere_light)
    
    print(f"Adding haze completed: {num_samples} samples processed")