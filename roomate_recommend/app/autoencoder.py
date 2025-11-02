import os
import torch
import torch.nn as nn
import json

device = torch.device("cpu")

class Autoencoder(nn.Module):
    def __init__(self, input_dim, hidden_dim=62, latent_dim=7):
        super(Autoencoder, self).__init__()
        self.encoder = nn.Sequential(
            nn.Linear(input_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, latent_dim)
        )
        self.decoder = nn.Sequential(
            nn.Linear(latent_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, input_dim),
            nn.Sigmoid()
        )

    def forward(self, x):
        z = self.encoder(x)
        x_hat = self.decoder(z)
        return x_hat



def load_model():
    # 현재 파일(app) 기준으로 상위 폴더로 이동 후 models 폴더 지정
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    save_dir = os.path.join(base_dir, "models")

    config_path = os.path.join(save_dir, "config.json")
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Config 파일을 찾을 수 없음: {config_path}")

    with open(config_path, "r") as f:
        config = json.load(f)

    model_path = os.path.join(save_dir, "Autoencoder_model.pth")
    model = Autoencoder(
        input_dim=config["input_dim"],
        hidden_dim=config.get("hidden_dim", 62),
        latent_dim=config.get("latent_dim", 7)
    )
    model.load_state_dict(torch.load(model_path, map_location=device))
    model.eval()
    return model
