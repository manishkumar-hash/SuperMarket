# Supermarket Swing app — Render deployment

This package keeps the existing Java Swing application and its compiled `.class` files unchanged. Because Swing is a desktop GUI, Render cannot show its window as a normal web page. This container runs the GUI in a virtual X display and exposes that desktop through noVNC in the browser.

## Included

- Original `.class` files, including the `SupermarketSystem$*.class` inner classes
- `products.csv` and `sales.csv` seed data
- `Dockerfile` for the Java 27 runtime plus Xvfb, x11vnc, Fluxbox and noVNC
- `start.sh` to start the desktop and browser VNC bridge
- `render.yaml` blueprint with a persistent disk for CSV data

## Deploy on Render

1. Create a GitHub repository and upload **all files in this folder** to its root.
2. In Render, choose **New + → Blueprint**, connect that repository, and apply `render.yaml`.
3. When prompted, set `VNC_PASSWORD` to a strong password (at least 6 characters). Keep it private.
4. Deploy. Open the service URL and choose **Connect** in the noVNC page. Enter the VNC password.
5. The Swing application should appear in the browser desktop.

You can also create a Render Web Service manually and select **Docker**. Use the repository root as the Dockerfile directory, set `VNC_PASSWORD`, and attach a persistent disk at `/var/data` (1 GB). The service must expose the HTTP port supplied by Render; the startup script uses `$PORT`.

## Data persistence

The app expects `products.csv` and `sales.csv` in its working directory. `start.sh` links those names to `/var/data/products.csv` and `/var/data/sales.csv`. The first deployment copies the supplied CSV files to the disk; later restarts keep the disk's copies. The included Blueprint declares a 1 GB disk.

## Important notes / limitations

- The uploaded classes report Java class-file version **71**, which corresponds to Java 27. The Docker image therefore uses `eclipse-temurin:27-jre-noble`. If that image tag is unavailable in the registry at deployment time, use an available Java 27 JRE image; Java 26 or older cannot run these class files.
- Only compiled `.class` files were supplied; no `.java` source files or build configuration were included. This package runs the supplied compiled classes as-is and cannot rebuild or modify them.
- This is a remotely accessible desktop session, not a browser-native redesign. It may feel slower than running Swing locally. Use a strong VNC password because anyone who can reach the service URL may reach the login page.
- Render's persistent disk is needed to retain CSV changes across deploys/restarts. The Blueprint uses the paid `starter` service plan and a 1 GB disk; check current Render pricing before deploying.
- The container has not been deployed to your Render account. You must connect the GitHub repository and create the service yourself.
