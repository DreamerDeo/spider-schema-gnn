cd /workspace
pip3 install -r requirements.txt

python -c "import nltk; nltk.download('punkt')"

allennlp predict trained_model/ $1 --predictor spider_discriminator --use-dataset-reader --cuda-device=0 --silent --output-file beam_predictions.jsonlines --include-package models.semantic_parsing.spider_parser --include-package dataset_readers.spider --include-package predictors.discriminator_dataset_generator --weights-file trained_model/model.th -o "{\"dataset_reader\":{\"keep_if_unparsable\":true, \"dataset_path\": \"dataset/database\", \"tables_file\":\"dataset/tables.json\"}}"

python3 rerank_beam_outputs.py --input-file beam_predictions.jsonlines --output-file $2 --model trained_model/reranker.th --sqlonly

# Evaluate
PYTHONPATH=. python3 semparse/worlds/evaluate.py --gold dataset/dev_gold.sql --pred predictions.sql --db dataset/database/ --table dataset/tables.json --etype match
