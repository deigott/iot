# Inception-of-Things (IoT) 
IOt is a small kubernetes clusters with CI implemented using ArgoCD and GitLab

Welcome to "Inception-of-Things (IoT)." In this documentation, I'll take you through the steps I followed to complete this System Administration exercise. Think of it as a casual conversation where I explain the project as if we were chatting over coffee. Let's dive in!

## Introduction

So, I had this exciting opportunity to work on a project called "Inception-of-Things (IoT)," which involved setting up a bunch of cool stuff related to System Administration. Here's a quick overview of what I did, the technologies I used, and how it all works.

## Table of Contents

- [Technologies and Tools](#technologies-and-tools)
- [Project Setup](#project-setup)
- [Getting Started](#getting-started)
- [Core Tasks](#core-tasks)
  - [Part 1: K3s and Vagrant](#part-1-k3s-and-vagrant)
  - [Part 2: K3s and Three Simple Applications](#part-2-k3s-and-three-simple-applications)
  - [Part 3: K3d and Argo CD](#part-3-k3d-and-argo-cd)
- [Bonus Challenge](#bonus-challenge)
- [Final Submission and Evaluation](#final-submission-and-evaluation)

## Technologies and Tools

Before we jump into the nitty-gritty, let me introduce you to the awesome technologies and tools that played a vital role in making this project happen:

- **K3s:** This is our lightweight Kubernetes friend that makes managing containers a breeze.
- **K3d:** Think of it as K3s's cousin that helps us run Kubernetes clusters inside Docker containers.
- **Vagrant:** Our go-to tool for managing virtual machines and development environments.
- **Docker:** The magical platform that enables us to develop, ship, and run applications in containers.
- **Argo CD:** Our trusty GitOps tool for continuous delivery and automated deployment on Kubernetes.
- **GitHub:** The online home for our project's code and collaboration.
- **Gitlab:** Another fantastic platform for source code management and DevOps.
- **kubectl:** Our trusty command-line companion for managing Kubernetes clusters.
- **Linux:** The OS that powers our virtual machines and keeps things running smoothly.

## Project Setup

Before we dive into the action, let me quickly walk you through how I set up the project environment. This included configuring virtual machines, setting up Kubernetes, and getting all the necessary tools in place.

## Getting Started

Ready to get your hands dirty? In this section, I'll guide you through the initial steps to start working on this project. We'll cover prerequisites, initial setup, and any required installations.

## Core Tasks

### Part 1: K3s and Vagrant

Our adventure begins with Part 1. Here, I'll show you how I set up not one but two virtual machines using Vagrant. We'll deploy K3s on these machines, and I'll explain why it's essential for what's to come.

### Part 2: K3s and Three Simple Applications

Part 2 is where the fun really starts. I'll walk you through deploying three straightforward web applications within our K3s cluster. You'll learn about Ingress and how we route requests to these apps.

### Part 3: K3d and Argo CD

In Part 3, we'll dive deeper. I'll introduce you to K3d, a tool that lets us run K3s clusters inside Docker containers. We'll set up a local Kubernetes cluster and explore how to use Argo CD for continuous integration and automated deployments.

## Bonus Challenge

Ready for a challenge? The bonus round is optional but exciting. I'll explain how we can integrate Gitlab into our project, configure it to work seamlessly with our cluster, and take our setup to the next level.

## Final Submission and Evaluation

In this section, we'll prepare our project for submission and discuss the evaluation process. We'll make sure that we've met all the mandatory requirements before exploring the bonus challenge.

Alright, now that you've got the lay of the land let's roll up our sleeves and get started with the project!
