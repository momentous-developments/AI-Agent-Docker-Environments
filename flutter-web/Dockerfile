# Flutter Web Development Docker Container
# Optimized for Flutter Web development without mobile SDKs
# Includes Google Chrome, Python tools, and full authentication support

FROM debian:12

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN echo "📦 Installing base system packages..." && \
    apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    wget \
    # Additional useful tools
    vim \
    nano \
    build-essential \
    # Required for zsh and oh-my-zsh
    zsh \
    fonts-powerline \
    locales \
    # Clean up
    && rm -rf /var/lib/apt/lists/* \
    && echo "✅ Base packages installed"

# Set locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set up new user with zsh as default shell
RUN useradd -ms /bin/zsh developer
USER developer
WORKDIR /home/developer

# Flutter SDK environment variables
ENV FLUTTER_HOME /home/developer/flutter
ENV FLUTTER_VERSION 3.32.0
ENV PATH ${PATH}:${FLUTTER_HOME}/bin

# Download and install Flutter SDK
RUN echo "🐦 Downloading Flutter SDK ${FLUTTER_VERSION}..." && \
    git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_HOME} && \
    cd ${FLUTTER_HOME} && \
    git checkout ${FLUTTER_VERSION} && \
    echo "✅ Flutter SDK installed"

# Pre-download Flutter dependencies and verify installation
RUN flutter precache && \
    flutter doctor -v

# Enable Flutter web support and disable mobile platforms
RUN flutter config --enable-web && \
    flutter config --no-enable-android && \
    flutter config --no-enable-ios && \
    echo "✅ Flutter configured for web-only development"

# Set Flutter to use stable channel
RUN flutter channel stable && flutter upgrade

# Switch to root to install gcloud and nodejs
USER root

# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js and Firebase CLI
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g firebase-tools && \
    rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Install additional tools for web development and testing
RUN echo "🛠️ Installing development tools..." && \
    apt-get update && apt-get install -y \
    # Image optimization tools
    optipng \
    jpegoptim \
    # Network tools for debugging (specific variant)
    netcat-openbsd \
    dnsutils \
    # JSON processor
    jq \
    # Tree view for file structure
    tree \
    # Additional testing tools
    xvfb \
    x11-utils \
    # Screenshot tools
    imagemagick \
    # Performance monitoring
    htop \
    curl \
    wget \
    # Python and pip
    python3 \
    python3-pip \
    python3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && echo "✅ Development tools installed"

# Install Playwright system dependencies for Chromium
RUN echo "🎭 Installing Playwright dependencies..." && \
    apt-get update && apt-get install -y --no-install-recommends \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libxshmfence1 \
    fonts-noto-color-emoji \
    ttf-unifont \
    libfontconfig1 \
    libfreetype6 \
    xfonts-cyrillic \
    xfonts-scalable \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-tlwg-loma-otf \
    && rm -rf /var/lib/apt/lists/* \
    && echo "✅ Playwright dependencies installed"

# Install Google Chrome (official, not Chromium)
RUN echo "🌐 Installing Google Chrome..." && \
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb && \
    rm -rf /var/lib/apt/lists/* \
    && echo "✅ Google Chrome installed"

# Install additional npm tools
RUN npm install -g \
    # HTTP server for testing builds
    http-server \
    # Lighthouse for web performance testing
    lighthouse \
    # Web vitals CLI
    web-vitals \
    # Puppeteer for browser automation
    puppeteer \
    # Playwright for cross-browser testing
    playwright \
    # Jest for JavaScript testing
    jest \
    # Web accessibility testing
    @axe-core/cli \
    # Bundle analyzer
    webpack-bundle-analyzer \
    # Security scanning
    retire \
    # Performance monitoring
    sitespeed.io

# Setup sudoers for developer user
COPY scripts/setup-sudoers.sh /tmp/setup-sudoers.sh
RUN chmod +x /tmp/setup-sudoers.sh && \
    /tmp/setup-sudoers.sh && \
    rm /tmp/setup-sudoers.sh

# Install sudo
RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*

# Switch back to developer user
USER developer

# Configure npm to use user directory for global packages
RUN mkdir -p ~/.npm-global && \
    npm config set prefix '~/.npm-global' && \
    echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc && \
    echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc

# Install Python packages for web scraping and automation
RUN echo "🐍 Installing Python packages..." && \
    pip3 install --user --break-system-packages \
    beautifulsoup4 \
    requests \
    Pillow \
    lxml \
    selenium \
    pandas \
    numpy \
    && echo "✅ Python packages installed"

# Configure environment variables (can be overridden at runtime)
# Note: GOOGLE_PROJECT_ID and CLOUDSDK_CORE_PROJECT will be set by docker-compose
ENV GOOGLE_APPLICATION_CREDENTIALS=/home/developer/.config/gcloud/application_default_credentials.json
ENV PATH=/home/developer/.local/bin:/home/developer/.npm-global/bin:$PATH
ENV NPM_CONFIG_PREFIX=/home/developer/.npm-global
ENV PYTHONPATH=/home/developer/.local/lib/python3.11/site-packages:$PYTHONPATH

# Claude Code configuration - maintain working directory across commands
ENV CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1

# Install Claude Code and other npm tools in user directory
RUN npm install -g @anthropic-ai/claude-code && \
    npm install -g firebase-tools && \
    npm install -g @playwright/mcp@latest

# Install Playwright browsers (as user to avoid permission issues)
# Note: System dependencies are already installed above
RUN npx playwright install chromium firefox webkit

# Install Flutter testing tools (modern alternatives)
RUN echo "🧪 Installing Flutter testing tools..." && \
    dart pub global activate dhttpd && \
    dart pub global activate webdev && \
    echo "✅ Flutter testing tools installed"

# Install Oh My Zsh and Powerlevel10k
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Copy custom configurations
COPY --chown=developer:developer config/.zshrc /home/developer/.zshrc
COPY --chown=developer:developer config/.p10k.zsh /home/developer/.p10k.zsh

# Copy helper scripts
COPY --chown=developer:developer scripts/container-auth.sh /home/developer/container-auth.sh
COPY --chown=developer:developer scripts/setup-authentication.sh /home/developer/setup-authentication.sh
COPY --chown=developer:developer scripts/ai-agent-helpers.sh /home/developer/ai-agent-helpers.sh
COPY --chown=developer:developer scripts/flutter-web-dev.sh /home/developer/flutter-web-dev.sh
COPY --chown=developer:developer scripts/setup-firebase.sh /home/developer/setup-firebase.sh
COPY --chown=developer:developer scripts/show-container-config.sh /home/developer/show-container-config.sh
RUN chmod +x /home/developer/*.sh

# Create necessary directories
RUN mkdir -p /home/developer/workspace /home/developer/.config/gcloud

# Authentication is handled by setup-authentication.sh in .zshrc already

WORKDIR /home/developer/workspace

# Expose ports for Flutter web development
# Flutter web server
EXPOSE 8080
# Flutter DevTools
EXPOSE 9100

# Set zsh as the default shell
SHELL ["/bin/zsh", "-c"]

# Default command to start with zsh
CMD ["/bin/zsh"]