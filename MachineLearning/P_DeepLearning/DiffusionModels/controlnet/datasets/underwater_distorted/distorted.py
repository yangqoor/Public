import pandas as pd
from huggingface_hub import hf_hub_url
import datasets
import os
from datasets import load_dataset, load_from_disk
from io import StringIO

_VERSION = datasets.Version("0.0.2")

_DESCRIPTION = "TODO"
_HOMEPAGE = "TODO"
_LICENSE = "TODO"
_CITATION = "TODO"

_FEATURES = datasets.Features(
    {
        "image": datasets.Image(),
        "conditioning_image": datasets.Image(),
        "text": datasets.Value("string"),
    },
)

# METADATA_URL = hf_hub_url(
#     "fusing/fill50k",
#     filename="train.jsonl",
#     repo_type="dataset",
# )

# IMAGES_URL = hf_hub_url(
#     "fusing/fill50k",
#     filename="images.zip",
#     repo_type="dataset",
# )

# CONDITIONING_IMAGES_URL = hf_hub_url(
#     "fusing/fill50k",
#     filename="conditioning_images.zip",
#     repo_type="dataset",
# )

_DEFAULT_CONFIG = datasets.BuilderConfig(name="default", version=_VERSION)


class distorted(datasets.GeneratorBasedBuilder):
    BUILDER_CONFIGS = [_DEFAULT_CONFIG]
    DEFAULT_CONFIG_NAME = "default"

    def _info(self):
        return datasets.DatasetInfo(
            description=_DESCRIPTION,
            features=_FEATURES,
            supervised_keys=None,
            homepage=_HOMEPAGE,
            license=_LICENSE,
            citation=_CITATION,
        )

    def _split_generators(self, dl_manager):
        # metadata_path = dl_manager.download(METADATA_URL)
        # images_dir = dl_manager.download_and_extract(IMAGES_URL)
        # conditioning_images_dir = dl_manager.download_and_extract(
        #     CONDITIONING_IMAGES_URL
        # )
        # base_url = 'e:/Z_Pan/controlnet/datasets/underwater_distorted'
        base_url = 'D:/underwater_distorted'

        metadata_path  = f'{base_url}/train.jsonl'
        images_dir = base_url
        conditioning_images_dir = base_url

        return [
            datasets.SplitGenerator(
                name=datasets.Split.TRAIN,
                # These kwargs will be passed to _generate_examples
                gen_kwargs={
                    "metadata_path": metadata_path ,
                    "images_dir": images_dir ,
                    "conditioning_images_dir": conditioning_images_dir ,
                },
            ),
        ]

    def _generate_examples(self, metadata_path, images_dir, conditioning_images_dir):
        metadata = pd.read_json(metadata_path, lines=True)

        for _, row in metadata.iterrows():
            text = row["text"]

            image_path = row["image"]
            image_path = os.path.join(images_dir, image_path)
            image = open(image_path, "rb").read()

            conditioning_image_path = row["conditioning_image"]
            conditioning_image_path = os.path.join(
                conditioning_images_dir, row["conditioning_image"]
            )
            conditioning_image = open(conditioning_image_path, "rb").read()

            yield row["image"], {
                "text": text,
                "image": {
                    "path": image_path,
                    "bytes": image,
                },
                "conditioning_image": {
                    "path": conditioning_image_path,
                    "bytes": conditioning_image,
                },
            }

# import datasets 
# config  = datasets.DownloadConfig(local_files_only=True) 
# dataset = datasets.load_dataset( "codeparrot/self-instruct-starcoder", cache_dir="./hf_cache", download_config=config )
dataset   = load_dataset(r'D:\Study\Code\Public\MachineLearning\P_DeepLearning\DiffusionModels\controlnet\datasets\underwater_distorted\distorted.py', trust_remote_code=True)
# print(dataset)
# print(dataset["train"][0])
