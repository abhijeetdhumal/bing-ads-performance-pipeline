import pathlib
from bing_ads_performance_pipeline import config

from data_integration.commands.files import ReadFile, Compression
from data_integration.commands.sql import ExecuteSQL
from data_integration.parallel_tasks.files import ParallelReadFile, ReadMode
from data_integration.pipelines import Pipeline, Task

pipeline = Pipeline(
    id="bing_ads",
    description="Builds the bing ads cube from csv files downloaded by cronjob",
    base_path=pathlib.Path(__file__).parent,
    labels={"Schema": "ba_dim"})

pipeline.add_initial(
    Task(
        id="initialize_schemas",
        description="Recreates the tmp and dim_next schemas",
        commands=[
            ExecuteSQL(sql_statement="DROP SCHEMA IF EXISTS ba_dim_next CASCADE; CREATE SCHEMA ba_dim_next;"),
            ExecuteSQL(sql_file_name="create_data_schema.sql", echo_queries=False,
                       file_dependencies=["create_data_schema.sql"]),
            ExecuteSQL(sql_file_name="recreate_schemas.sql", echo_queries=False)
        ]))

pipeline.add(
    Task(
        id="read_account_structure",
        description="Loads the bing account structure",
        commands=[
            ExecuteSQL(sql_file_name="create_account_structure_data_table.sql", echo_queries=False),
            ReadFile(file_name="bing-account-structure_{}.csv.gz".format(config.input_file_version()),
                     compression=Compression.GZIP, skip_header=True,
                     target_table="ba_data.account_structure",
                     delimiter_char="\t", null_value_string="", timezone="Europe/Berlin", csv_format=True)
        ]))

pipeline.add(
    ParallelReadFile(
        id="read_ad_performance",
        description="Loads the ad performance csv file set",
        file_pattern="*/*/*/bing/ad_performance_{}.csv.gz".format(config.input_file_version()),
        read_mode=ReadMode.ONLY_CHANGED,
        compression=Compression.ZIP,
        mapper_script_file_name="read_csv.py",
        target_table="ba_data.ad_performance_upsert",
        delimiter_char="\t", null_value_string='""',
        date_regex="^(?P<year>\d{4})\/(?P<month>\d{2})\/(?P<day>\d{2})/",
        file_dependencies=['create_ad_performance_data_table.sql'],
        commands_before=[
            ExecuteSQL(sql_file_name="create_ad_performance_data_table.sql", echo_queries=False,
                       file_dependencies=['create_ad_performance_data_table.sql'])
        ],
        commands_after=[
            ExecuteSQL(sql_statement='SELECT ba_data.upsert_ad_performance()')
        ]))

pipeline.add(
    Task(
        id="preprocess_ad",
        description="Extracts campaign structure information",
        commands=[
            ExecuteSQL(sql_file_name="preprocess_ad.sql")
        ]),
    ["read_account_structure", "read_ad_performance"])

pipeline.add(
    Task(
        id="transform_ad",
        description="Creates the ad dimension table",
        commands=[
            ExecuteSQL(sql_file_name="transform_ad.sql")
        ]),
    ["preprocess_ad"])

pipeline.add(
    Task(
        id="transform_ad_performance",
        description="Creates the bing_ads_performance dimension table",
        commands=[
            ExecuteSQL(sql_file_name="transform_ad_performance.sql")
        ]),
    ["read_ad_performance", "read_account_structure"])

pipeline.add_final(
    Task(
        id="replace_schema",
        description="Replaces the current ba_dim schema with the contents of ba_dim_next",
        commands=[
            ExecuteSQL(sql_statement="SELECT ba_tmp.constrain_ad_performance()"),
            ExecuteSQL(sql_statement="SELECT util.replace_schema('ba_dim', 'ba_dim_next');")]))
