using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Configuration;
using System.Data.SqlClient;

namespace Tema2SGBD
{
    public partial class Form1 : Form
    {
        SqlConnection dbConn;
        SqlDataAdapter daChild, daParent;
        DataSet ds;
        BindingSource bsChild, bsParent;
        SqlCommandBuilder cbChild;


        public Form1()
        {
            InitializeComponent();
        }

        private string getConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["connection_string"].ConnectionString.ToString();
        }

        private string getPKName()
        {
            return ConfigurationManager.AppSettings["parent_table_pk"];
        }

        private string getPKChildName()
        {
            return ConfigurationManager.AppSettings["child_table_pk"];
        }

        private string getFKName()
        {
            return ConfigurationManager.AppSettings["child_table_fk"];
        }

        private string getParentTable()
        {
            return ConfigurationManager.AppSettings["parent_table"];
        }

        private string getParentQuery()
        {
            return ConfigurationManager.AppSettings["parent_query"];
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            dbConn = new SqlConnection(getConnectionString());

            daParent = new SqlDataAdapter(getParentQuery(), dbConn);
            daChild = new SqlDataAdapter(getChildQuery(), dbConn);

            cbChild = new SqlCommandBuilder(daChild);

            ds = new DataSet();

            daParent.Fill(ds, getParentTable());
            daChild.Fill(ds, getChildTable());

            DataRelation dr = new DataRelation("fk_child_parent",
                ds.Tables[getParentTable()].Columns[getPKName()],
                ds.Tables[getChildTable()].Columns[getFKName()]);

            ds.Relations.Add(dr);

            //binding source for parent
            bsParent = new BindingSource();
            bsParent.DataSource = ds;
            bsParent.DataMember = getParentTable();

            //binding source for child
            bsChild = new BindingSource();
            bsChild.DataSource = bsParent;
            bsChild.DataMember = "fk_child_parent";

            parentView.DataSource = bsParent;
            childView.DataSource = bsChild;

        }

        private void parentView_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void childView_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void Add_Click(object sender, EventArgs e)
        {
            try
            {
                dbConn = new SqlConnection(getConnectionString());
                dbConn.Open();
                //int nrCells = childView.SelectedCells.Count;
                if (childView.SelectedCells.Count > 0)
                {
                    daChild = new SqlDataAdapter(getChildQuery(), dbConn);
                    cbChild = new SqlCommandBuilder(daChild);
                    cbChild.GetInsertCommand();
                    daChild.Update(ds, getChildTable());
                    MessageBox.Show("Modificare realizata cu succes!");
                }
                else
                {
                    MessageBox.Show("Nicio inregistrare selectata!");
                }
                dbConn.Close();



            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            ds.Tables[getChildTable()].Clear();
            daChild.Fill(ds, getChildTable());
        }

        private void Modify_Click(object sender, EventArgs e)
        {
            try
            {
                dbConn = new SqlConnection(getConnectionString());
                dbConn.Open();
                //int nrCells = childView.SelectedCells.Count;
                if (childView.SelectedCells.Count > 0)
                {
                    daChild = new SqlDataAdapter(getChildQuery(), dbConn);
                    cbChild = new SqlCommandBuilder(daChild);
                    cbChild.GetUpdateCommand();
                    //daChild.UpdateCommand.ExecuteNonQuery();
                    daChild.Update(ds, getChildTable());
                    MessageBox.Show("Modificare realizata cu succes!");
                }
                else
                {
                    MessageBox.Show("Nicio inregistrare selectata!");
                }
                dbConn.Close();

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            ds.Tables[getChildTable()].Clear();
            daChild.Fill(ds, getChildTable());

        }

        private void Remove_Click(object sender, EventArgs e)
        {
            try
            {
                dbConn = new SqlConnection(getConnectionString());

                dbConn.Open();
                int nrCells = childView.SelectedCells.Count;
                if (childView.SelectedCells.Count > 0)
                {
                    int indexOfRow = childView.SelectedCells[0].RowIndex;
                    string codChild = childView.Rows[indexOfRow].Cells[0].Value.ToString();
                    SqlCommand deleteCommand = new SqlCommand(getChildDeleteQuery(), dbConn);
                    deleteCommand.Parameters.AddWithValue("@codChild", codChild);
                    deleteCommand.ExecuteNonQuery();
                    MessageBox.Show("Stergere realizata cu succes!");
                }
                else
                {
                    MessageBox.Show("Nicio inregistrare selectata!");
                }
                dbConn.Close();

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            ds.Tables[getChildTable()].Clear();
            daChild.Fill(ds, getChildTable());
        }

    
        private string getChildTable()
        {
            return ConfigurationManager.AppSettings["child_table"];
        }


        private string getChildQuery()
        {
            return ConfigurationManager.AppSettings["child_query"];
        }

        private string getChildDeleteQuery()
        {
            return ConfigurationManager.AppSettings["delete_from_child_query"];
        }        

    }
}

