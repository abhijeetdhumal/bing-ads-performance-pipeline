from setuptools import setup, find_packages

setup(
    name='bing-ads-performance-pipeline',
    version='1.0.0',
    description="A data integration pipeline that imports downloaded Bing Ads performance data into a data warehouse",

    install_requires=[
        'bingads-performance-downloader>=2.2.1',
        'etl-tools>=1.1.0',
        'data-integration>=1.3.0'
    ],

    dependency_links=[
        'git+https://github.com/mara/bingads-performance-downloader.git@2.2.1#egg=bingads-performance-downloader-2.2.1',
        'git+https://github.com/mara/etl-tools.git@1.1.0#egg=etl-tools-1.1.0',
        'git+https://github.com/mara/data-integration.git@1.3.0#egg=data-integration-1.3.0'

    ],

    packages=find_packages(),

    author='Mara contributors',
    license='MIT'
)
