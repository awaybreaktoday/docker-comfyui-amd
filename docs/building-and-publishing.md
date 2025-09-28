# Building & Publishing

## 🚫 Why Builds Must Stay Local

- **PyTorch ROCm wheel size**: `torch-2.8.0+rocm6.4` is ~3.6 GB. Cloud builders regularly hit network and timeout limits.
- **ROCm runtime dependencies**: The wheel bundles HIP, MIOpen, rocBLAS, rocFFT, rocRAND, Tensile, and kernels for every supported architecture. Download + extraction routinely exceeds 30 minutes.
- **Quota constraints**: Free tiers (GitHub Actions, Docker Hub, GitLab CI, CircleCI) cap runtime at 2–6 hours and disk at 14–25 GB. Multi-platform builds double those requirements.
- Result: Remote builds fail intermittently or never finish. Cache reuse is unreliable because the PyTorch layer invalidates on every run.

**Bottom line:** build locally, then push a finished artifact. CI can lint or publish but should not attempt the Docker build.

## 🛠️ Recommended Workflow

1. **Prepare host dependencies**
   - Install ROCm 6.4.4 on the host.
   - Verify Docker can access `/dev/kfd` and `/dev/dri` (user in `video` and `render` groups).

2. **Fetch custom nodes & models**
   ```bash
   ./setup-comfyui.sh
   ./download-models.sh --essential   # optional flags: --animatediff, --wan, --all
   ```

3. **Build the runtime image once**
   ```bash
   ./build-local.sh \
     --maintainer-name "Your Name" \
     --dockerhub-user yourdockerhub  # optional; adds a second tag
   ```
   - Creates a reusable local tag (`comfyui-rocm:local` by default).
   - Optional `--local-tag` overrides the compose image name.

4. **Start ComfyUI**
   ```bash
   ./run.sh
   # or docker compose up -d
   ```

5. **Publish (optional)**
   ```bash
   ./quick-push.sh yourdockerhub v1.0
   # For scripted pushes with extra tagging:
   ./push-to-dockerhub.sh yourdockerhub v1.0 v1.0-rc1
   ```

## 🧰 Storage & Caching Tips

- Ensure **15 GB of free disk** before the first build (`df -h`). Subsequent builds reuse the cached PyTorch layer and drop to ~5 GB.
- Use `docker system df` to monitor cache usage. Clean aggressively with `docker system prune -a` if space gets tight.
- Keep models on a separate volume (`./models` is bind-mounted) so pruning containers never removes downloads.

## ⚙️ Build Optimizations Already Applied

- Multi-stage `Dockerfile.cloudbuild` strips build tooling from the runtime image (≈30–45 % smaller).
- PyTorch install uses extended timeouts/retries and stays on the stable ROCm channel.
- Metadata (labels, docs URL, ROCm version) is injected via build arguments for traceability.
- `docker-compose.yml` reuses the local tag, avoiding rebuilds on every `run.sh` invocation.

## 🔄 Updating the Image

When upstream changes land:

```bash
git pull
./setup-comfyui.sh          # if node set changes
./build-local.sh --version 1.0.1-local
./run.sh
```

Use `./update.sh` for a forced rebuild with `--no-cache` and `--pull` if you suspect stale layers.

## 🧪 Testing & Troubleshooting

- Validate GPU visibility from the container:
  ```bash
  docker compose exec comfyui-rocm-6.4.4 python -c "import torch; print(torch.cuda.is_available())"
  ```
- If a build fails mid-way, the partially downloaded wheel may leave the layer dirty. Rerun `./build-local.sh`; Docker will resume the download.
- For ROCm library mismatches, confirm `/opt/rocm` is mounted read-only from the host and matches 6.4.4.

## 📦 Publishing Checklist

- [ ] Local image present (`docker image inspect comfyui-rocm:local`)
- [ ] Docker Hub credentials available (`docker login`)
- [ ] `quick-push.sh` or `push-to-dockerhub.sh` run successfully
- [ ] README updated with any new tags or features before publishing

Keeping the entire workflow on your hardware yields predictable build times and avoids the cloud-service lottery. Once the image is pushed, downstream machines can simply `docker pull` and skip the 30–60 minute build altogether.
