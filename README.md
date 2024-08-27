# Blog App - Ruby on Rails

## Description

A simple blog application built with Ruby on Rails. Users can register, log in, create, edit, and delete their own blogs. Users can also search through blog content and view public blogs. This application uses PostgreSQL as the database.

## Features

- **User Registration**: Register with display name, username, and password.
- **User Authentication**: Login with username and password.
- **User Profile Management**: Update username, display name and password.
- **Blog Management**:
  - Create blogs with a title, body and is_public option.
  - Edit and delete own blogs.
  - List blogs ordered by date.
  - Search blog content.
  - View only own blogs (private to the user).
  - Make blogs public so that anyone can view them.
- **Database**: PostgreSQL.

## Setup

### 1. Clone the Repository

```bash
mkdir blog-app
cd blog-app
git clone https://github.com/cshiva256/blog_app.git .
```

### 2. Install Dependencies

Ensure you have the necessary gems installed:

```bash
bundle install
```

### 3. Configure Database

Set up the database configuration in `config/database.yml`. Ensure you have PostgreSQL installed and running.

Create the databases: (run only once)

```bash
rails db:create
```

Run migrations to set up the database schema:

```bash
rails db:migrate
```

### 4. Seed the Database (Optional)

If you want to populate the database with initial data, you can use:

```bash
rails db:seed
```

### 5. Start the Rails Server

```bash
rails server
```

Visit `http://localhost:3000` in your web browser to start using the application.

## Usage

### User Registration

1. Navigate to `/users/sign_up`.
2. Provide a display name, username, and password.
3. Submit the form to register.

### User Login

1. Navigate to `/users/sign_in`.
2. Enter your username and password.
3. Submit the form to log in.

### User Profile Management

1. After logging in, navigate to `/users/edit`.
2. Update your user name, display name and/or password.
3. Submit the form to save changes.

### Blog Management

- **Create a Blog**:

  1. Navigate to `/blogs/new`.
  2. Enter a title, body for the blog and select is_public check box.
  3. Submit the form to create the blog.

- **Edit a Blog**:

  1. Navigate to `/blogs/:id/edit` (where `:id` is the ID of the blog).
  2. Update the title, body and is_public option.
  3. Submit the form to save changes.

- **Delete a Blog**:

  1. Navigate to the blog’s show page (`/blogs/:id`).
  2. Click on the delete button.

- **View Public Blogs**:

  1. Navigate to `/blogs` to view all public blogs.

- **View Private Blogs**:

  1. Navigate to `/blogs/view` to view private blogs.

- **Search Blogs**:

  1. Use the search bar on the `/blogs` and `/blogs/view` index page to search through blog content.

By default the blogs are listed in order of date.

### Authorization

- Users can only view, edit, or delete their own blogs.
- Other users cannot modify blogs that do not belong to them. they can only see public blogs.

## Testing

To run tests, run the following command:

```bash
rspec
```
