import pandas as pd
from pathlib import Path

input_path = Path("data") / "input" / "snippet.csv"
df = pd.read_csv(input_path)
