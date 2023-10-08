import docker
import os

from plasticome.config.celery_config import celery_app


@celery_app.task
def run_ecpred_container(absolute_mount_dir):
    """
    The function `run_ecpred_container` runs a Docker container with the image
    `blueevee/ecpred:latest` and mounts a directory to the container, then executes
    a command within the container and returns the path to the output file with the
    ec numbers predicted to the enzymes.

    :param absolute_mount_dir: The absolute path of the directory where the input
    file is located
    :return: The function `run_ecpred_container` returns a tuple containing two
    values. The first value is `output_file_path`, which is the path to the output
    file generated by the container. The second value is a boolean `False` if the
    container runs successfully, or a string containing an error message if an
    exception occurs during the container execution.
    """

    input_file = os.path.basename(absolute_mount_dir)
    local_mount_dir = os.path.dirname(absolute_mount_dir)
    docker_mount = os.path.basename(local_mount_dir)

    output_folder_name = f'{input_file.split(".")[0]}_results'
    output_file_path = os.path.join(local_mount_dir, output_folder_name, f'{output_folder_name}.tsv')

    if not os.path.exists(os.path.dirname(output_file_path)):
        os.makedirs(os.path.dirname(output_file_path))

    client = docker.from_env()

    container_params = {
        'image': 'blueevee/ecpred:latest',
        'volumes': {local_mount_dir: {'bind': f'/app/{docker_mount}', 'mode': 'rw'}},
        'working_dir': '/app',
        'command': ['spmap', f'./{docker_mount}/{input_file}', './', '/temp', f'./{docker_mount}/{output_folder_name}/{output_folder_name}.tsv'],
        'remove': True,
    }
    try:
        client.containers.run(**container_params)
        return output_file_path, False
    except Exception as e:
        return False, f'[ECPRED STEP] - Unexpected error: {e}'
