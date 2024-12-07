using DemoGPLX.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using System.Text;
using System.Text.Json.Serialization;

namespace API_GPLX.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CauhoiController : ControllerBase
    {
        [HttpPost("{id}")]
        public IActionResult GetData(int id)
        {
            var data = QuestionUtil.GetDataForMobile(id);
            return Ok(data);
        }

        [HttpPost("length")]
        public IActionResult GetLengthData(int id)
        {
            var data = QuestionUtil.GetDataForMobile(id);
            var json = JsonSerializer.Serialize(data);
            var jsonBytes = Encoding.UTF8.GetBytes(json);
            var contentLength = json.Length;
            return Ok(contentLength);
        }
        [HttpGet("chuong")]
        public IActionResult GetChapter()
        {
            return Ok(QuestionUtil.GetDataChapterForMobile());
        }
        [HttpGet("hang")]
        public IActionResult GetType()
        {
            return Ok(QuestionUtil.GetDataTypeForMobile());
        }
        [HttpGet("thi")]
        public IActionResult GetType(int id)
        {
            return Ok(QuestionUtil.GetTest(id));
        }

        [HttpGet("thongtinhang")]
        public IActionResult GetTypeFromID(int id)
        {
            return Ok(QuestionUtil.GetTest(id));
        }

    }
}
