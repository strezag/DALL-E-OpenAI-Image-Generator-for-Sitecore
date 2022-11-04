# DALL-E OpenAI Image Generator for Sitecore

- [DALL-E OpenAI Image Generator for Sitecore](#dall-e-openai-image-generator-for-sitecore)
  - [⚙ DALL-E Image Generation Configuration](#-dall-e-image-generation-configuration)
    - [Prompt](#prompt)
    - [Settings](#settings)
  - [💻 Installation](#-installation)
  - [📄 DALL-E Resources](#-dall-e-resources)
  - [🌟 Contributions](#-contributions)

---


> 💡 Corresponding Blog Post: <br/>
> - [https://www.sitecoregabe.com/2022/11/dall-e-openai-image-generator-for-sitecore.html](https://www.sitecoregabe.com/2022/11/dall-e-openai-image-generator-for-sitecore.html)


---



`DALL-E OpenAI Image Generator for Sitecore` is a Sitecore PowerShell Extensions utility that enables Designers, Developers, and Marketers to generate images using the DALL-E Open Artificial Intelligence directly in Sitecore's Media Library.

<img src="./img/spe_leaves.gif">
<img src="./img/spe_fabrics.gif">
<img src="./img/spe_chicago.gif">

---

<br/>

## ⚙ DALL-E Image Generation Configuration

### Prompt
> <img src="./img/DALL-E OpenAI Image Generator for Sitecore-Prompt.png">

<br/>

### Settings

An OpenAI API key is required:
- [https://beta.openai.com/account/api-keys](https://beta.openai.com/account/api-keys)

This key is configured in the `OpenAI API Key` field on the `OpenAI API Setting` item installed alongside this module in Sitecore:
- `/sitecore/system/Modules/PowerShell/Script Library/DALL-E OpenAI Image Generator/OpenAI API Settings`
- `{F102AE0D-6A5B-499B-9500-505D0E6F686F}`

> <img src="./img/DALL-E OpenAI Image Generator for Sitecore-Modules.png">

<br/>

The Sitecore Template for this setting item is located here:
- `/sitecore/templates/Modules/DALL-E OpenAI Image Generator`


<br/>

## 💻 Installation

- Download the latest Sitecore package from the repo's [Releases](https://github.com/strezag/DALL-E-OpenAI-Image-Generator-for-Sitecore/releases) section.

- Install the `Sitecore Package` on an instance of Sitecore where Sitecore PowerShell Extensions is already installed.

- Configure the `OpenAI API Key` field on the on the module's Settings item. 

- From the Sitecore `Desktop`, select `Start Menu` > PowerShell Toolbox > `Rebuild script integration points`

<br/>

## 📄 DALL-E Resources
- [https://openai.com/dall-e-2](https://openai.com/dall-e-2)
- [https://labs.openai.com/](https://labs.openai.com/)
- [https://beta.openai.com/docs/guides/images/usage](https://beta.openai.com/docs/guides/images/usage)
- [https://beta.openai.com/docs/api-reference/images](https://beta.openai.com/docs/api-reference/images)
- [https://openai.com/blog/dall-e-api-now-available-in-public-beta/](https://openai.com/blog/dall-e-api-now-available-in-public-beta/)


<br/>

## 🌟 Contributions

Community contributions are more than welcome.  Create a PR and I'll be happy to review and merge.

<br/>