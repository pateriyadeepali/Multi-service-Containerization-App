import React, { useState, useEffect } from "react";

const API_URL = process.env.REACT_APP_API_URL || "http://backend:5000";

function App() {
  const [bookName, setBookName] = useState("");
  const [author, setAuthor] = useState("");
  const [year, setYear] = useState("");
  const [books, setBooks] = useState([]);

  // Fetch books from backend
  useEffect(() => {
    fetch(`${API_URL}/all`)
      .then((res) => res.json())
      .then((data) => {
        if (Array.isArray(data)) setBooks(data);
        else console.error("Unexpected response:", data);
      })
      .catch((err) => console.error("Error fetching books:", err));
  }, []);

  // Handle form submit
  const handleSubmit = async (e) => {
    e.preventDefault();
    const newBook = { bookName, author, year };

    try {
      const res = await fetch(`${API_URL}/add`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(newBook),
      });

      const data = await res.json();
      if (data && data._id) {
        setBooks((prevBooks) => [...prevBooks, data]);
        setBookName("");
        setAuthor("");
        setYear("");
      } else {
        console.error("Unexpected response from backend:", data);
      }
    } catch (err) {
      console.error("Error adding book:", err);
    }
  };

  // Delete book
  const handleDelete = async (id) => {
    try {
      await fetch(`${API_URL}/delete/${id}`, { method: "DELETE" });
      setBooks((prevBooks) => prevBooks.filter((b) => b._id !== id));
    } catch (err) {
      console.error("Error deleting book:", err);
    }
  };

  return (
    <div style={{ maxWidth: "800px", margin: "20px auto", textAlign: "center" }}>
      <h1>Book Store Application</h1>

      <form onSubmit={handleSubmit} style={{ marginBottom: "20px" }}>
        <input
          type="text"
          placeholder="Book Name"
          value={bookName}
          onChange={(e) => setBookName(e.target.value)}
          required
          style={{ padding: "8px", margin: "5px" }}
        />
        <input
          type="text"
          placeholder="Author"
          value={author}
          onChange={(e) => setAuthor(e.target.value)}
          required
          style={{ padding: "8px", margin: "5px" }}
        />
        <input
          type="number"
          placeholder="Year Published"
          value={year}
          onChange={(e) => setYear(e.target.value)}
          required
          style={{ padding: "8px", margin: "5px" }}
        />
        <button type="submit" style={{ padding: "10px 15px", margin: "5px" }}>
          Add Book
        </button>
      </form>

      <table border="1" cellPadding="10" style={{ width: "100%", marginTop: "20px" }}>
        <thead>
          <tr>
            <th>Book Name</th>
            <th>Author</th>
            <th>Year Published</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          {books.length > 0 ? (
            books.map((book) => (
              <tr key={book._id}>
                <td>{book.bookName}</td>
                <td>{book.author}</td>
                <td>{book.year}</td>
                <td>
                  <button
                    onClick={() => handleDelete(book._id)}
                    style={{ background: "red", color: "white", padding: "5px 10px" }}
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan="4">No books available</td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

export default App;
